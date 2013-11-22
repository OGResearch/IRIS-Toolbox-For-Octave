function [YMean,YInit] = mean(This,Alt)
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
% * `X` [ numeric ] - Mean vector.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    Alt; %#ok<VUNUS>
catch %#ok<CTCH>
    Alt = 1 : size(This.A,3);
end

isYInit = nargout > 1;

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

if p == 0
    YMean = This.K(:,:,Alt);
    if isYInit
        YInit = zeros(ny,0,nAlt);
    end
    return
end

nAlt = numel(Alt);
realSmall = getrealsmall();

if isnumericscalar(Alt) && ~isinf(Alt)
    [YMean,YInit] = doOneAlt(Alt);
else
    YMean = nan(size(This.K));
    if isYInit
        YInit = nan(ny,p,nAlt);
    end
    for iAlt = 1 : nAlt
        [iYMean,iYInit] = doOneAlt(IAlt);
        YMean(:,:,iAlt) = iYMean;
        if isYInit
            YInit(:,:,iAlt) = iYInit;
        end
    end
end

% Nested functions.

%**************************************************************************
    function [IYMean,IYInit] = doOneAlt(IAlt)
        unit = abs(abs(This.eigval(1,:,IAlt)) - 1) <= realSmall;
        nUnit = sum(unit);
        IYInit = [];
        if nUnit == 0
            % Stationary parameterisation
            %-----------------------------
            IYMean = sum(poly.var2poly(This.A(:,:,IAlt)),3) ...
                \ This.K(:,:,IAlt);
            if isYInit
                % The function `mean` requests YInit only when called on VAR, not PVAR
                % objects; at this point, the size of `m` is guaranteed to be 1 in 2nd
                % dimension.
                IYInit(:,1:p) = IYMean(:,ones(1,p));
            end
        else
            % Unit-root parameterisation
            %----------------------------
            [T,~,k,~,~,~,U] = sspace(This,IAlt);
            a2 = (eye(ny*p-nUnit) - T(nUnit+1:end,nUnit+1:end)) ...
                \ k(nUnit+1:end,:);
            % Return NaNs for unit-root variables.
            dy = any(abs(U(1:ny,unit)) > realSmall,2).';
            IYMean = nan(size(This.K,1),size(This.K,2));
            IYMean(~dy,:) = U(~dy,nUnit+1:end)*a2;
            if isYInit
                init = U*[zeros(nUnit,1);a2];
                init = reshape(init,ny,p);
                IYInit(:,:) = init(:,end:-1:1);
            end
        end
    end % doOneAlt().

end
