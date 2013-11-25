function [X,Y,XX,YY] = fevd(This,Time)
% fevd  Forecast error variance decomposition for SVAR variables.
%
% Syntax
% =======
%
%     [X,Y,XX,YY] = fevd(V,NPer)
%     [X,Y,XX,YY] = fevd(V,Range)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - Structural VAR model.
%
% * `NPer` [ numeric ] - Number of periods.
%
% * `Range` [ numeric ] - Date range.
%
% Output arguments
% =================
%
% * `X` [ numeric ] - Forecast error variance decomposition into absolute
% contributions of residuals; absolute contributions sum up to the total
% variance.
%
% * `Y` [ numeric ] - Forecast error variance decomposition into relative
% contributions of residuals; relative contributions sum up to `1`.
%
% * `XX` [ tseries ] - `X` converted to a tseries object.
%
% * `YY` [ tseries ] - `Y` converted to a tseries object.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Tell whether time is nper or range.
[range,nPer] = varobj.mytelltime(Time);

%--------------------------------------------------------------------------

ny = size(This.A,1);
nAlt = size(This.A,3);

Phi = timedom.var2vma(This.A,This.B,nPer);
X = cumsum(Phi.^2,3);
Y = nan(size(X));
varVec = This.std .^ 2;
for iAlt = 1 : nAlt
    for t = 1 : nPer
        if varVec(iAlt) ~= 1
            X(:,:,t,iAlt) = X(:,:,t,iAlt) .* varVec(iAlt);
        end
        Xsum = sum(X(:,:,t,iAlt),2);
        Xsum = Xsum(:,ones(1,ny));
        Y(:,:,t,iAlt) = X(:,:,t,iAlt) ./ Xsum;
    end
end

if nargout > 2
    XX = tseries(range,permute(X,[3,1,2,4]));
end

if nargout > 3
    YY = tseries(range,permute(Y,[3,1,2,4]));
end

end
