function Outp = resample(This,Inp,Range,NDraw,varargin)
% resample  Resample from a VAR object.
%
% Syntax
% =======
%
%     Outp = resample(V,Inp,Range,NDraw,...)
%     Outp = resample(V,[],Range,NDraw,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object to resample from.
%
% * `Inp` [ struct | tseries ] - Input database or tseries used in
% bootstrap; not needed when `'method=' 'montecarlo'`.
%
% * `Range` [ numeric ] - Range for which data will be returned.
%
% Output arguments
% =================
%
% * `Outp` [ struct | tseries ] - Resampled output database or tseries.
%
% Options
% ========
%
% * `'deviation='` [ `true` | *`false`* ] - Do not include the constant
% term in simulations.
%
% * `'group='` [ numeric | *`NaN`* ] - Choose group whose parameters will
% be used in resampling; required in VAR objects with multiple groups when
% `'deviation=' false`.
%
% * `'method='` [ 'bootstrap' | *'montecarlo'* | function_handle ] -
% Bootstrap from estimated residuals, resample from normal distribution, or
% use user-supplied sampler.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the
% command window.
%
% * `'randomise='` [ `true` | *`false`* ] - Randomise or fix pre-sample
% initial condition.
%
% * `'wild='` [ `true` | *`false`* ] - Use wild bootstrap instead of
% standard Efron bootstrap when `'method=' 'bootstrap'`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Handle obsolete syntax.
throwWarn = false;
if nargin < 4
    % resample(w,data,ndraw)
    NDraw = Range;
    Range = Inf;
    throwWarn = true;
elseif ischar(NDraw)
    % resample(w,data,ndraw,...)
    varargin = [{NDraw},varargin];
    NDraw = Range;
    Range = Inf;
    throwWarn = true;
end

if throwWarn
    warning('iris:VAR', ...
        ['Calling VAR.resample with three input arguments is obsolete, ', ...
        'and will not be supported in future versions of IRIS.\n']);
end

% Parse required input arguments.
pp = inputParser();
pp.addRequired('V',@isvar);
pp.addRequired('Inp',@(x) isempty(x) || myisvalidinpdata(This,x));
pp.addRequired('Range',@isnumeric);
pp.addRequired('NDraw',@(x) isnumericscalar(x) && x == round(x) && x >= 0);
pp.parse(This,Inp,Range,NDraw);

% Panel VAR.
if ispanel(This)
    Outp = mygroupmethod(@resample,This,Inp,Range,NDraw,varargin{:});
    return
end

% Parse options.
opt = passvalopt('VAR.resample',varargin{:});

if ischar(opt.method)
    opt.method = lower(opt.method);
end

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

% Check for multiple parameterisations.
doChkMultipleParams();

if isequal(Range,Inf)
    Range = This.range(1) + p : This.range(end);
end

xRange = Range(1)-p : Range(end);
nXPer = numel(xRange);

% Input data
%------------
[outpFmt,~,y,e] = mydatarequest(This,Inp,xRange,opt);
nData = size(y,3);
if nData > 1
    utils.error('VAR', ...
        'Cannot resample from multiple data sets.')
end

% Pre-allocate an array for resampled data and initialise
%---------------------------------------------------------
Y = nan(ny,nXPer);
if opt.deviation
    Y(:,1:p) = 0;
else
    if isempty(Inp)
        % Asymptotic initial condition.
        [~,x] = mean(This);
        Y(:,1:p) = x;
    else
        % Initial condition from pre-sample data.
        Y(:,1:p) = y(:,1:p);
    end
end
if NDraw > 1
    Y = Y(:,:,ones(1,NDraw));
end

% TODO: randomise initial condition
%{
if options.randomise
else
end
%}

% System matrices
%-----------------
[A,B,K] = mysystem(This);

% Back out reduced-form residuals if needed. The B matrix is then
% discarded, and only the covariance matrix of reduced-form residuals is
% used.
Be = B*e;

if ~isequal(opt.method,'bootstrap')
    % Safely factorise (chol/svd) the covariance matrix of reduced-form
    % residuals so that we can draw from multivariate normal.
    F = covfun.factorise(This.Omega);
    if isa(opt.method,'function_handle')
        allSampleE = opt.method(ny*(nXPer-p),NDraw);
    end
end

% Create a command-window progress bar.
if opt.progress
    progress = progressbar('IRIS VAR.resample progress');
end

% Simulate
%----------
nanInit = false(1,NDraw);
nanResid = false(1,NDraw);
for iDraw = 1 : NDraw
    iBe = zeros(ny,nXPer);
    iBe(:,p+1:end) = doDrawResiduals();
    Yi = Y(:,:,iDraw);
    if any(any(isnan(Yi(:,1:p))))
        nanInit(iDraw) = true;
    end
    if any(isnan(iBe(:)))
        nanResid(iDraw) = true;
    end
    for t = p+1 : nXPer
        Yilags = Yi(:,t-(1:p));
        Yi(:,t) = A*Yilags(:) + iBe(:,t);
        if ~opt.deviation
            Yi(:,t) = Yi(:,t) + K;
        end
    end
    Y(:,:,iDraw) = Yi;
    % Update the progress bar.
    if opt.progress
        update(progress,iDraw/NDraw);
    end
end

% Report NaNs in initial conditions.
if any(nanInit)
    utils.warning('VAR', ...
        'Some of the initial conditions for resampling are NaN:%s.', ...
        preparser.alt2str(nanInit));
end

% Report NaNs in resampled residuals.
if any(nanResid)
    utils.warning('VAR', ...
        'Some of the resampled residuals are NaN:%s.', ...
        preparser.alt2str(nanResid));
end

% Return only endogenous variables, not shocks.
Outp = myoutpdata(This,outpFmt,xRange,Y,[],This.Ynames);

% Nested functions.

%**************************************************************************
    function doChkMultipleParams()
        
        % Works only with single parameterisation and single group.
        if nAlt > 1
            utils.error('VAR', ...
                ['Cannot resample from VAR objects ', ...
                'with multiple parameterisations.']);
        end
    end % doChkMultipleParams().

%**************************************************************************
    function X = doDrawResiduals()
        if isequal(opt.method,'bootstrap')
            if opt.wild
                % Wild bootstrap.
                % Setting draw = ones(1,nper-p) would reproduce sample.
                draw = randn(1,nXPer-p);
                X = Be(:,p+1:end).*draw(ones(1,ny),:);
            else
                % Standard Efron bootstrap.
                % Setting draw = 1 : nper-p would reproduce sample;
                % draw is uniform integer [1,nper-p].
                draw = randi([1,nXPer-p],[1,nXPer-p]);
                X = Be(:,p+draw);
            end
        else
            if isa(opt.method,'function_handle')
                thisSampleE = allSampleE(:,iDraw);
                thisSampleE = reshape(thisSampleE,[ny,nXPer-p]);
            else
                thisSampleE = randn(ny,nXPer-p);
            end
            X = F*thisSampleE;
        end
    end % doDrawResiduals().

end

