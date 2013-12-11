function [X,D,D1] = fmse(This,Time,varargin)
% fmse  Forecast mean square error matrices.
%
% Syntax
% =======
%
%     [M,X] = fmse(V,NPer)
%     [M,X] = fmse(V,Range)
%
% Input arguments
% ================
%
% * `C` [ VAR ] - VAR object for which the forecast MSE matrices will be
% computed.
%
% * `NPer` [ numeric ] - Number of periods.
%
% * `Range` [ numeric ] - Date range.
%
% Output arguments
% =================
%
% * `M` [ numeric ] - Forecast MSE matrices.
%
% * `X` [ dbase | tseries ] - Database or tseries with the std deviations
% of individual variables, i.e. the square roots of the corresponding
% diagonal elements of `M`.
%
% Options
% ========
%
% * `'output='` [ *`'namedmat'`* | `'numeric'` ] - Return matrix `M` as
% either namedmat object (matrix with named rows and columns) or plain
% numeric array.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

opt = passvalopt('VAR.fmse',varargin{:});

% Tell whether time is nper or range.
if length(Time) == 1 && round(Time) == Time && Time > 0
    range = 1 : Time;
else
    range = Time(1) : Time(end);
end
nPer = length(range);

%--------------------------------------------------------------------------

ny = size(This.A,1);
nAlt = size(This.A,3);

% Orthonormalise residuals so that we do not have to multiply the VMA
% representation by Omega.
B = covfun.factorise(This.Omega);

% Get VMA representation.
X = timedom.var2vma(This.A,B,nPer);

% Compute FMSE matrices.
for iAlt = 1 : nAlt
    for t = 1 : nPer
        X(:,:,t,iAlt) = X(:,:,t,iAlt)*transpose(X(:,:,t,iAlt));
    end
end
X = cumsum(X,3);

yNames = get(This,'yNames');
if ~isempty(yNames) && strcmpi(opt.output,'namedmat')
    X = namedmat(X,yNames,yNames);
end

% Return std devs for individual series.
templ = tseries();
if nargout > 1
    x = nan(nPer,ny,nAlt);
    for i = 1 : ny
        x(:,i,:) = sqrt(permute(X(i,i,:,:),[3,1,4,2]));
    end
    % ##### Nov 2013 OBSOLETE and scheduled for removal.
    % All VAR output data will be returned as dbase (struct).
    if ~isempty(yNames)
        D = struct();
        for i = 1 : ny
            tmp = x(:,i,:);
            D.(yNames{i}) = replace(templ,tmp(:,:),range(1));
        end
    else
        D = replace(templ,x,range(1),yNames(1,:,ones(1,nAlt)));
    end
    if nargout > 2
        % ##### Nov 2013 OBSOLETE and scheduled for removal.
        D1 = D;
        utils.warning('obsolete', ...
            ['Syntax with more than 2 output arguments is obsolete, ', ...
            'and will be removed from IRIS in the future.']);
    end
end

end