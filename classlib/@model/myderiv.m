function [This,D,NanDeriv] = myderiv(This,EqSelect,IAlt,Symbolic,Linear)
% myderiv  [Not a public function] Compute first-order expansion of equations around current steady state.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

isNanDeriv = nargout > 2;

%--------------------------------------------------------------------------

% Copy last computed derivatives.
D = struct();
D.c = This.deriv0.c;
D.f = This.deriv0.f;
D.n = This.deriv0.n;

assign = This.Assign(1,:,IAlt);
nName = length(This.name);
nEqtn = length(This.eqtn);
EqSelect(This.eqtntype >= 3) = false;

NanDeriv = false(1,nEqtn);

% Prepare 3D occur array limited to occurences of variables and shocks in
% measurement and transition equations.
occur = full(This.occur);
occur = reshape(occur,[nEqtn,nName,size(This.occur,2)/nName]);
occur = occur(This.eqtntype <= 2,This.nametype <= 3,:);
occur = permute(occur,[3,2,1]);

if any(EqSelect)
    
    nt = size(This.occur,2) / nName;
    nVar = sum(This.nametype <= 3);
    t = This.tzero;
    if Symbolic
        symbSelect = ~cellfun(@isempty,This.deqtnF);
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
    D.n(EqSelect,:) = tempEye(EqSelect,This.nonlin);
    
    % Normalise derivatives by largest number in non-linear models.
    if ~Linear
        for iEq = find(EqSelect)
            inx = D.f(iEq,:) ~= 0;
            if any(inx)
                norm = max(abs(D.f(iEq,inx)));
                D.f(iEq,inx) = D.f(iEq,inx) / norm;
                D.n(iEq,:) = D.n(iEq,:) / norm;
            end
        end
    end
    
end

if IAlt == 1
    This.Assign0(:) = This.Assign(1,:,IAlt);
    This.deriv0.c(:) = D.c;
    This.deriv0.f(:) = D.f;
    This.deriv0.n(:) = D.n;
end


% Nested functions.


%**************************************************************************


    function doNumDeriv()
        
        minT = 1 - t;
        maxT = nt - t;
        tVec = minT : maxT;
        
        if Linear
            init = zeros(1,nName);
            init(1,This.nametype == 4) = real(assign(This.nametype == 4));
            init = init(1,:,ones(1,nt));
            h = ones(1,nName,nt);
        else
            init = mytrendarray(This,1:nName,tVec,false,IAlt);
            init = shiftdim(init,-1);
            h = abs(This.epsilon(1))*max([init;ones(1,nName,nt)],[],1);
        end
        
        xPlus = init + h;
        xMinus = init - h;
        step = xPlus - xMinus;
        
        if any(This.log)
            init(1,This.log,:) = exp(init(1,This.log,:));
            xPlus(1,This.log,:) = exp(xPlus(1,This.log,:));
            xMinus(1,This.log,:) = exp(xMinus(1,This.log,:));
        end
        
        % References to steady-state levels and growth rates.
        if ~Linear
            L = init(:,:,t);
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
                gridMinus(ii,nmOcc(ii),tmOcc(ii)) = ...
                    xMinus(1,nmOcc(ii),tmOcc(ii));
                gridPlus(ii,nmOcc(ii),tmOcc(ii)) = ...
                    xPlus(1,nmOcc(ii),tmOcc(ii));
            end
            
            x = gridMinus;
            fMinus = eqtn(x,t,L);
            x = gridPlus;
            fPlus = eqtn(x,t,L);
            
            % Constant in linear models.
            if Linear
                x = grid;
                D.c(iiEq) = eqtn(x,t,L);
            end
            
            value = zeros(1,n);
            for ii = 1 : n
                value(ii) = (fPlus(ii)-fMinus(ii)) ...
                    / step(1,nmOcc(ii),tmOcc(ii));
            end
            
            % Assign values to the array of derivatives.
            inx = (tmOcc-1)*nVar + nmOcc;
            D.f(iiEq,inx) = value;
            
            % Check for NaN derivatives.
            if isNanDeriv && any(~isfinite(value))
                NanDeriv(iiEq) = true;
            end

        end
        
    end % doNumDeriv()


%**************************************************************************

    
    function doSymbDeriv()

        if Linear
            x = zeros(1,nName);
            if any(This.log)
                x(1,This.log) = 1;
            end
            x(1,This.nametype == 4) = real(assign(This.nametype == 4));
            x = x(1,:,ones(1,nt));
            % References to steady-state levels and growth rates.
            L = [];
        else
            minT = 1 - t;
            maxT = nt - t;
            tVec = minT : maxT;
            x = mytrendarray(This,1:nName,tVec,true,IAlt);
            x = shiftdim(x,-1);
            % References to steady-state levels and growth rates.
            L = x;
        end
   
        for iiEq = find(symbSelect)
            % Get occurences of variables in this equation.
            [tmOcc,nmOcc] = find(occur(:,:,iiEq));
            
            % Constant in linear models. Becuase all variables are set to
            % zero, evaluating the equations gives the constant.
            if Linear
                if isnumeric(This.ceqtnF{iiEq})
                    c = This.ceqtnF{iiEq};
                else
                    c = This.ceqtnF{iiEq}(x,t,L);
                end
                D.c(iiEq) = c;
            end
            
            % Evaluate all derivatives of the equation at once.
            value = This.deqtnF{iiEq}(x,t,L);
            
            % Assign values to the array of derivatives.
            inx = (tmOcc-1)*nVar + nmOcc;
            D.f(iiEq,inx) = value;
            
            % Check for NaN derivatives.
            if isNanDeriv && any(~isfinite(value))
                NanDeriv(iiEq) = true;
            end

        end
        
    end % doSymbDeriv()


end
