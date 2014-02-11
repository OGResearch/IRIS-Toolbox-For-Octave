function [YMean,YInit] = mean(This)
% mean  Mean of VAR process.
%
% Syntax
% =======
%
%     X = mean(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% Output arguments
% =================
%
% * `X` [ numeric ] - Asymptotic mean of the VAR variables.
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
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

isYInit = nargout > 1;

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

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
        unit = abs(abs(This.eigval(1,:,IAlt)) - 1) <= realSmall;
        nUnit = sum(unit);
        Init = [];
        if nUnit == 0
            % Stationary parameterisation
            %-----------------------------
            Mean = sum(poly.var2poly(This.A(:,:,IAlt)),3) ...
                \ This.K(:,:,IAlt);
            if isYInit
                % The function `mean` requests YInit only when called on VAR, not PVAR
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


end
