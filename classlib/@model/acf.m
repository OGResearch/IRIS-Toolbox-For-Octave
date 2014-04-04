function [CC,RR,List] = acf(This,varargin)
% acf  Autocovariance and autocorrelation functions for model variables.
%
% Syntax
% =======
%
%     [C,R,List] = acf(M,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Solved model object for which the ACF will be computed.
%
% Output arguments
% =================
%
% * `C` [ namedmat | numeric ] - Auto/cross-covariance matrices.
%
% * `R` [ namedmat | numeric ] - Auto/cross-correlation matrices.
%
% * `List` [ cellstr ] - List of variables in rows and columns of `C` and
% `R`.
%
% Options
% ========
%
% * `'applyTo='` [ cellstr | char | *`Inf`* ] - List of variables to which
% the `'filter='` will be applied; `Inf` means all variables.
%
% * `'contributions='` [ `true` | *`false`* ] - If `true` the contributions
% of individual shocks to ACFs will be computed and stored in the 5th
% dimension of the `C` and `R` matrices.
%
% * `'filter='` [ char  | *empty* ] - Linear filter that is applied to
% variables specified by 'applyto'.
%
% * `'nFreq='` [ numeric | *`256`* ] - Number of equally spaced frequencies
% over which the filter in the option `'filter='` is numerically
% integrated.
%
% * `'order='` [ numeric | *`0`* ] - Order up to which ACF will be
% computed.
%
% * `'output='` [ *`'namedmat'`* | `'numeric'` ] - Return matrices `C` and
% `R` as either namedmat objects (matrices with named rows and columns) or
% plain numeric arrays; if the option `'select='` is used, `'output='` is
% always a namedmat object.
%
% * `'select='` [ cellstr | *`Inf`* ] - Return ACF for selected variables
% only; `Inf` means all variables.
%
% Description
% ============
%
% `C` and `R` are both N-by-N-by-(P+1)-by-Alt matrices, where N is the
% number of measurement and transition variables (including auxiliary lags
% and leads in the state space vector), P is the order up to which the ACF
% is computed (controlled by the option `'order='`), and Alt is the number
% of alternative parameterisations in the input model object, `M`. If
% `'contributions=' true`, the size of the two matrices is
% N-by-N-by-(P+1)-by-E-Alt, where E is the number of measurement and
% transition shocks in the model.
%
%
% ACF with linear filters 
% ------------------------
%
% You can use the option `'filter='` to get the ACF for variables as though
% they were filtered through a linear filter. You can specify the filter in
% both the time domain (such as first-difference filter, or
% Hodrick-Prescott) and the frequncy domain (such as a band of certain
% frequncies or periodicities). The filter is a text string in which you
% can use the following references:
%
% * `'L'`, the lag operator, which will be replaced with `exp(-1i*freq)`;
% * `'per'`, the periodicity;
% * `'freq'`, the frequency.
% 
% Example
% ========
%
% A first-difference filter (i.e. computes the ACF for the first
% differences of the respective variables):
%
%     [C,R] = acf(m,'filter=','1-L')
%
% Example
% ========
%
% The cyclical component of the Hodrick-Prescott filter with the
% smoothing parameter, $lambda$, 1,600. The formula for the filter follows
% from the classical Wiener-Kolmogorov signal extraction theory,
%
% $$w(L) = \frac{\lambda}{\lambda + \frac{1}{ | (1-L)(1-L) | ^2}}$$
%
%     [C,R] = acf(m,'filter','1600/(1600 + 1/abs((1-L)^2)^2)')
%
% Example
% ========
%
% A band-pass filter with user-specified lower and upper bands. The
% band-pass filters can be defined either in frequencies or periodicities;
% the latter is usually more convenient. The following is a filter which
% retains periodicities between 4 and 40 periods (this would be between 1
% and 10 years in a quarterly model),
%
%     [C,R] = acf(m,'filter','per >= 4 & per <= 40')

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

opt = passvalopt('model.acf',varargin{:});

if ischar(opt.select)
    opt.select = regexp(opt.select, ...
        '[a-zA-Z][\w\(\)\{\}\+\-]*','match');
elseif isempty(opt.select)
    opt.select = {''};
end

isSelect = iscellstr(opt.select);
isNamedMat = strcmpi(opt.output,'namedmat') || isSelect;

%--------------------------------------------------------------------------

ny = length(This.solutionid{1});
nx = length(This.solutionid{2});
ne = length(This.solutionid{3});
nAlt = size(This.Assign,3);

if opt.contributions
    nCont = ne;
else
    nCont = 1;
end
CC = nan(ny+nx,ny+nx,opt.order+1,nCont,nAlt);

% Pre-process filter options.
sspaceVec = [This.solutionvector{1:2}];
[isFilter,filter,freq,applyTo] = freqdom.applyfilteropt(opt,[],sspaceVec);


% Call timedom package to compute autocovariance function.
isContributions = opt.contributions;
acfOrder = opt.order;
isSolution = true(1,nAlt);
for iAlt = 1 : nAlt
    isExpand = false;
    [T,R,~,Z,H,~,U,Omg] = mysspace(This,iAlt,isExpand);

    % Continue immediately if solution is not available.
    isSolution(iAlt) = all(~isnan(T(:)));
    if ~isSolution(iAlt)
        continue
    end

    for iCont = 1 : nCont
        if isContributions
            inx = false(1,ne);
            inx(iCont) = true;
            if Omg(inx,inx) == 0
                CC(:,:,:,iCont,iAlt) = 0;
                continue
            end
        else
            inx = true(1,ne);
        end
        if isFilter
            nUnit = mynunit(This,iAlt);
            S = freqdom.xsf( ...
                T,R(:,inx),[],Z,H(:,inx),[],U,Omg(inx,inx),nUnit, ...
                freq,filter,applyTo);
            CC(:,:,:,iCont,iAlt) = freqdom.xsf2acf(S,freq,acfOrder);
        else
            CC(:,:,:,iCont,iAlt) = covfun.acovf( ...
                T,R(:,inx),[],Z,H(:,inx),[],U,Omg(inx,inx), ...
                This.eigval(1,:,iAlt),acfOrder);
        end
    end
end

% Report NaN solutions.
if ~all(isSolution)
    utils.warning('model', ...
        'Solution(s) not available:%s.', ...
        preparser.alt2str(~isSolution));
end

% Squeeze the covariance matrices if ~contributions.
if ~opt.contributions
    CC = reshape(CC,ny+nx,ny+nx,opt.order+1,nAlt);
end

% Fix negative variances (in the contemporaneous matrices).
CC(:,:,1,:,:) = timedom.fixcov(CC(:,:,1,:,:));

% Autocorrelation function.
if nargout > 1
    % Convert covariances to correlations.
    RR = covfun.cov2corr(CC,'acf');
end

List = [This.solutionvector{1:2}];

% Convert double arrays to namedmat objects.
if isNamedMat
    CC = namedmat(CC,List,List);
    try %#ok<TRYNC>
        RR = namedmat(RR,List,List);
    end
end

% Select variables.
if isSelect
    [CC,inx] = select(CC,opt.select);
    try %#ok<TRYNC>
        RR = RR(inx{1},inx{2},:,:,:);
    end
end

end