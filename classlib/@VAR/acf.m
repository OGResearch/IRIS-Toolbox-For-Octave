function [C,Q] = acf(This,varargin)
% acf  Autocovariance and autocorrelation functions for VAR variables.
%
% Syntax
% =======
%
%     [C,R] = acf(V,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object for which the ACF will be computed.
%
% Output arguments
% =================
%
% * `C` [ numeric ] - Auto/cross-covariance matrices.
%
% * `R` [ numeric ] - Auto/cross-correlation matrices.
%
% Options
% ========
%
% * `'applyTo='` [ logical | *`Inf`* ] - Logical index of variables to
% which the `'filter='` will be applied; the default Inf means all
% variables.
%
% * `'filter='` [ char  | *empty* ] - Linear filter that is applied to
% variables specified by 'applyto'.
%
% * `'nfreq='` [ numeric | *`256`* ] - Number of equally spaced frequencies
% over which the 'filter' is numerically integrated.
%
% * `'order='` [ numeric | *`0`* ] - Order up to which ACF will be
% computed.
%
% * `'output='` [ *`'namedmat'`* | `'numeric'` ] - Return matrices `C` and
% `R` as either namedmat objects (matrices with named rows and columns) or
% plain numeric arrays.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the command
% window.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

opt = passvalopt('VAR.acf',varargin{:});
isCorr = nargout > 1;

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

% Pre-process filter options.
[isFilter,filter,freq,applyTo] ...
    = freqdom.applyfilteropt(opt,[],This.Ynames);

C = nan(ny,ny,opt.order+1,nAlt);

% Find explosive parameterisations.
explosive = isexplosive(This);

if opt.progress
    pBar = progressbar('IRIS VAR.acf progress');
end

for iAlt = find(~explosive)
    [T,R,~,~,~,~,U,Cov] = sspace(This,iAlt);
    if isFilter
        S = freqdom.xsfvar(This.A(:,:,iAlt),Cov,freq,filter,applyTo);
        C(:,:,:,iAlt) = freqdom.xsf2acf(S,freq,opt.order);
    else
        % Compute contemporaneous ACF for its first-order state space form.
        % This gives us autocovariances up to order p-1.
        c = covfun.acovf(T,R,[],[],[],[],U,Cov,This.eigval(1,:,iAlt),0);
        if p > 1
            c0 = c;
            c = reshape(c0(1:ny,:),ny,ny,p);
        end
        if p == 0
            c(:,:,end+1:opt.order+1) = 0;
        elseif opt.order > p - 1
            % Compute higher-order acfs using Yule-Walker equations.
            c = xxAcovYW(This.A(:,:,iAlt),c,opt.order);
        else
            c = c(:,:,1:1+opt.order);
        end
        C(:,:,:,iAlt) = c;
    end
    % Update the progress bar.
    if opt.progress
        update(pBar,iAlt/sum(~explosive));
    end
end

if any(explosive)
    % Report explosive parameterisations.
    utils.warning('VAR', ...
        'Cannot compute ACF for explosive parameterisations:%s.', ...
        preparser.alt2str(explosive));
end

% Fix entries with negative variances.
C = timedom.fixcov(C);

% Autocorrelation function.
if isCorr
    % Convert covariances to correlations.
    Q = covfun.cov2corr(C,'acf');
end

% Convert output to named matrices.
if strcmp(opt.output,'namedmat')
    yNames = This.Ynames;
    if length(yNames) == ny
        C = namedmat(C,yNames,yNames);
        if isCorr
            Q = namedmat(Q,yNames,yNames);
        end
    end
end

end


% Subfunctions...


%**************************************************************************
function C = xxAcovYW(A,C,P)

[ny,pNy] = size(A);
p = pNy/ny;

% Residuals included or not in ACF.
ne = size(C,1) - ny;

A = reshape(A(:,1:ny*p),ny,ny,p);
C = C(:,:,1+(0:p-1));
for i = p : P
    X = zeros(ny,ny+ne);
    for j = 1 : size(A,3)
        X = X + A(:,:,j)*C(1:ny,:,end-j+1);
    end
    C(1:ny,:,1+i) = X;
end

end % xxAcovYW()