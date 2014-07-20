function [YMean,YInit] = mean(This)
% mean  Mean of VAR process.
%
% Syntax
% =======
%
%     M = mean(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% Output arguments
% =================
%
% * `M` [ numeric ] - Asymptotic mean of the VAR variables.
%
% Description
% ============
%
% For plain VAR objects, the output argument `X` is a column vector where
% the k-th number is the asymptotic mean of the k-th variable, or `NaN` if
% the k-th variable is non-stationary (contains a unit root).
%
% In panel VAR objects (with a total of Ng groups) and/or VAR objects with
% multiple alternative parameterisations (with a total of Na
% parameterisations), `X` is an Ny-by-Ng-by-Na matrix in which the column
% `X(:,g,a)` is the asyptotic mean of the VAR variables in the g-th group
% and the a-th parameterisation.
%
% In VAR objects with exogenous inputs, the mean will be
% computed based on the asymptotic assumptions of exogenous inputs assigned
% by the function [`xasymptote`](VAR/xasymptote).
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

isYInit = nargout > 1;

%--------------------------------------------------------------------------

ny = size(This.A,1);
nx = length(This.XNames);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);
nGrp = max(1,length(This.GroupNames));

% Add the effect of exogenous inputs to the constant term, This.K. This
% will work also in `sspace(...)`.
if nx > 0
    KJ = This.K;
    X0 = This.X0;
    doExog();
    This.K(:,:,:) = KJ;
end

if p == 0
    YMean = This.K;
    if isYInit
        YInit = zeros(ny,0,nAlt);
    end
    return
end

realSmall = getrealsmall();

YMean = nan(size(This.K));
if isYInit
    YInit = nan(ny,p,nAlt);
end
for iAlt = 1 : nAlt
    [iMean,iInit] = doMean(iAlt);
    YMean(:,:,iAlt) = iMean;
    if isYInit
        YInit(:,:,iAlt) = iInit;
    end
end


% Nested functions...


%**************************************************************************


    function [Mean,Init] = doMean(IAlt)
        unit = abs(abs(This.EigVal(1,:,IAlt)) - 1) <= realSmall;
        nUnit = sum(unit);
        Init = [];
        if nUnit == 0
            % Stationary parameterisation
            %-----------------------------
            Mean = sum(poly.var2poly(This.A(:,:,IAlt)),3) ...
                \ This.K(:,:,IAlt);
            if isYInit
                % The function `mean` requests YInit only when called on VAR, not panel VAR
                % objects; at this point, the size of `m` is guaranteed to be 1 in 2nd
                % dimension.
                Init(:,1:p) = Mean(:,ones(1,p));
            end
        else
            % Unit-root parameterisation
            %----------------------------
            [T,~,k,~,~,~,U] = sspace(This,IAlt);
            a2 = (eye(ny*p-nUnit) - T(nUnit+1:end,nUnit+1:end)) ...
                \ k(nUnit+1:end,:);
            % Return NaNs for unit-root variables.
            dy = any(abs(U(1:ny,unit)) > realSmall,2).';
            Mean = nan(size(This.K,1),size(This.K,2));
            Mean(~dy,:) = U(~dy,nUnit+1:end)*a2;
            if isYInit
                init = U*[zeros(nUnit,1);a2];
                init = reshape(init,ny,p);
                Init(:,:) = init(:,end:-1:1);
            end
        end
    end % doMean()


%**************************************************************************


    function doExog()
        if any(isnan(X0(:)))
            utils.warning('VAR:mean', ...
                ['Cannot compute VAR mean. ', ...
                'Asymptotic mean assumptions for exogenous inputs ', ...
                'contain NaNs.']);
        end
        if all(X0(:) == 0)
            return
        end
        if nx > 0
            for iiAlt = 1 : nAlt
                for iiGrp = 1 : nGrp
                    pos = (iiGrp-1)*nx + (1:nx);
                    iiX = X0(:,iiGrp,iiAlt);                    
                    iiJ = This.J(:,pos,iiAlt);
                    KJ(:,iiGrp,iiAlt) = KJ(:,iiGrp,iiAlt) + iiJ*iiX;
                end
            end
        end
    end % doExog()


end
