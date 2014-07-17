function [Derv,NanDerv] = myderiv(This,EqSelect,IAlt,Opt)
% myderiv  [Not a public function] Compute first-order expansion of equations around current steady state.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

isNanDeriv = nargout > 2;

if isequal(Opt.linear,@auto)
    Opt.linear = This.IsLinear;
end

%--------------------------------------------------------------------------

realexp = @(x) real(exp(x));

% Copy last computed derivatives.
Derv = This.lastSyst.derv;

assign = This.Assign(1,:,IAlt);
nName = length(This.name);
nEqtn = length(This.eqtn);
EqSelect(This.eqtntype >= 3) = false;

NanDerv = false(1,nEqtn);

% Prepare 3D occur array limited to occurences of variables and shocks in
% measurement and transition equations.
occur = full(This.occur);
occur = reshape(occur,[nEqtn,nName,size(This.occur,2)/nName]);
occur = occur(This.eqtntype <= 2,This.nametype <= 3,:);
occur = permute(occur,[3,2,1]);

if any(EqSelect)
    
    nt = length(This.Shift);
    nVar = sum(This.nametype <= 3);
    t0 = find(This.Shift == 0);
    if Opt.symbolic
        symbSelect = ~cellfun(@isempty,This.DEqtnF);
    else
        symbSelect = false(1,nEqtn);
    end
    symbSelect = symbSelect & EqSelect;
    numSelect = ~symbSelect & EqSelect;
    
    if any(symbSelect)
        % Symbolic derivatives.
        doSymbDeriv();
    end
    if any(numSelect)
        % Numerical derivatives.
        doNumDeriv();
    end
    
    % Reset the add-factors in non-linear equations to 1.
    tempEye = -eye(sum(This.eqtntype <= 2));
    Derv.n(EqSelect,:) = tempEye(EqSelect,This.IxNonlin);
    
    % Normalise derivatives by largest number in non-linear models.
    if ~Opt.linear && Opt.Normalize
        for iEq = find(EqSelect)
            inx = Derv.f(iEq,:) ~= 0;
            if any(inx)
                norm = max(abs(Derv.f(iEq,inx)));
                Derv.f(iEq,inx) = Derv.f(iEq,inx) / norm;
                Derv.n(iEq,:) = Derv.n(iEq,:) / norm;
            end
        end
    end
end


% Nested functions...


%**************************************************************************


    function doNumDeriv()
        minT = 1 - t0;
        maxT = nt - t0;
        tVec = minT : maxT;
        
        if Opt.linear
            init = zeros(1,nName);
            init(1,This.nametype == 4) = real(assign(This.nametype == 4));
            init = init(1,:,ones(1,nt));
            h = ones(1,nName,nt);
        else
            isDelog = false;
            init = mytrendarray(This,IAlt,isDelog,1:nName,tVec);
            init = shiftdim(init,-1);
            h = abs(This.epsilon(1))*max([init;ones(1,nName,nt)],[],1);
        end
        
        xPlus = init + h;
        xMinus = init - h;
        % Any imag parts in `xPlus` and `xMinus` should cancel; `real()` does no
        % harm here therefore.
        step = real(xPlus - xMinus);
        
        % Delog log-plus variables.
        if any(This.IxLog)
            init(1,This.IxLog,:) = realexp(init(1,This.IxLog,:));
            xPlus(1,This.IxLog,:) = realexp(xPlus(1,This.IxLog,:));
            xMinus(1,This.IxLog,:) = realexp(xMinus(1,This.IxLog,:));
        end
        
        % References to steady-state levels and growth rates.
        if ~Opt.linear
            L = init(:,:,t0);
        else
            L = [];
        end
        
        for iiEq = find(numSelect)
            eqtn = This.eqtnF{iiEq};
            
            % Get occurences of variables in this equation.
            [tmOcc,nmOcc] = find(occur(:,:,iiEq));
            
            % Total number of derivatives to be computed in this equation.
            n = length(nmOcc);
            grid = init;
            gridPlus = init(ones(1,n),:,:);
            gridMinus = init(ones(1,n),:,:);
            for ii = 1 : n
                iNm = nmOcc(ii);
                iTm = tmOcc(ii);
                gridMinus(ii,iNm,iTm) = xMinus(1,iNm,iTm);
                gridPlus(ii,iNm,iTm) = xPlus(1,iNm,iTm);
            end
            
            x = gridMinus;
            fMinus = eqtn(x,t0,L);
            x = gridPlus;
            fPlus = eqtn(x,t0,L);
            
            % Constant in linear models.
            if Opt.linear
                x = grid;
                Derv.c(iiEq) = eqtn(x,t0,L);
            end
            
            value = zeros(1,n);
            for ii = 1 : n
                value(ii) = (fPlus(ii)-fMinus(ii)) ...
                    / step(1,nmOcc(ii),tmOcc(ii));
            end
            
            % Assign values to the array of derivatives.
            inx = (tmOcc-1)*nVar + nmOcc;
            Derv.f(iiEq,inx) = value;
            
            % Check for NaN derivatives.
            if isNanDeriv && any(~isfinite(value))
                NanDerv(iiEq) = true;
            end
        end
    end % doNumDeriv()


%**************************************************************************

    
    function doSymbDeriv()
        if Opt.linear
            x = zeros(1,nName);
            x(1,This.IxLog) = 1;
            x(1,This.nametype == 4) = real(assign(This.nametype == 4));
            x = x(1,:,ones(1,nt));
            % References to steady-state levels.
            L = [];
        else
            isDelog = true;
            x = mytrendarray(This,IAlt,isDelog);
            x = shiftdim(x,-1);
            % References to steady-state levels.
            L = x;
        end
   
        for iiEq = find(symbSelect)
            % Get occurences of variables in this equation.
            [tmOcc,nmOcc] = find(occur(:,:,iiEq));
            
            % Log derivatives need to be multiplied by x. Log-plus and
            % log-minus variables are treated the same way because
            % df(x)/dlog(xm) = df(x)/d(x) * d(x)/d(xm) * d(xm)/dlog(xm) 
            % = df(x)/d(x) * (-1) * xm = df(x)/d(x) * (-1) * (-1)*x
            % = df(x)/d(x) *x.
            ixLog = This.IxLog(nmOcc);
            if any(ixLog)
                logMult = ones(size(nmOcc));
                for iiOcc = find(ixLog)
                    logMult(iiOcc) = x(1,nmOcc(iiOcc),tmOcc(iiOcc));
                end
            end
            
            % Constant in linear models. Becuase all variables are set to
            % zero, evaluating the equations gives the constant.
            if Opt.linear
                if isnumeric(This.CEqtnF{iiEq})
                    c = This.CEqtnF{iiEq};
                else
                    c = This.CEqtnF{iiEq}(x,t0,L);
                end
                Derv.c(iiEq) = c;
            end
            
            % Evaluate all derivatives of the equation at once.
            value = This.DEqtnF{iiEq}(x,t0,L);
            
            % Multiply derivatives wrt to log variables by x.
            if any(ixLog)
                value = value .* logMult;
            end

            % Assign values to the array of derivatives.
            inx = (tmOcc-1)*nVar + nmOcc;
            Derv.f(iiEq,inx) = value;
            
            % Check for NaN derivatives.
            if isNanDeriv && any(~isfinite(value))
                NanDerv(iiEq) = true;
            end
        end
    end % doSymbDeriv()


end
