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
% * `'method='` [ `'bootstrap'` | *`'montecarlo'`* | function_handle ] -
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
    % ##### Nov 2013 OBSOLETE.
    utils.warning('obsolete', ...
        ['Calling VAR/resample( ) with three input arguments is obsolete, ', ...
        'and will not be supported in future versions of IRIS.\n']);
end

% Parse required input arguments.
pp = inputParser();
pp.addRequired('Inp',@(x) isempty(x) || myisvalidinpdata(This,x));
pp.addRequired('Range',@isnumeric);
pp.addRequired('NDraw',@(x) isintscalar(x) && x >= 0);
pp.parse(Inp,Range,NDraw);

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
nx = length(This.XNames);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);
isConst = ~opt.deviation;
isX = nx > 0;

% Check for multiple parameterisations.
doChkMultipleParams();

if isequal(Range,Inf)
    Range = This.Range(1) + p : This.Range(end);
end

xRange = Range(1)-p : Range(end);
nXPer = numel(xRange);

% Input data
%------------
req = datarequest('y*,x,e',This,Inp,xRange,opt);
outpFmt = req.Format;
y = req.Y;
x = req.X;
e = req.E;
nData = size(y,3);
if nData > 1
    utils.error('VAR:resample', ...
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
        [~,init] = mean(This);
        Y(:,1:p) = init;
        x = This.X0;
        x = x(:,ones(1,nXPer));
        x(:,1:p) = NaN;
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
[A,~,K,J] = mysystem(This);
[B,isIdentified] = mybmatrix(This);

% Collect all deterministic terms (constant and exogenous inputs).
KJ = zeros(ny,nXPer);
if isConst
    KJ = KJ + K(:,ones(1,nXPer));
end
if isX
    KJ = KJ + J*x;
end

% Back out reduced-form residuals if needed. The B matrix is then
% discarded, and only the covariance matrix of reduced-form residuals is
% used.
if isIdentified
    Be = B*e;
end

if ~isequal(opt.method,'bootstrap')
    % Safely factorise (chol/svd) the covariance matrix of reduced-form
    % residuals so that we can draw from uncorrelated multivariate normal.
    F = covfun.factorise(This.Omega);
    if isa(opt.method,'function_handle')
        allSampleE = opt.method(ny*(nXPer-p),NDraw);
    else
        allSampleE = randn(ny*(nXPer-p),NDraw);
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
E = nan(ny,nXPer,NDraw);
for iDraw = 1 : NDraw
    iBe = zeros(ny,nXPer);
    iBe(:,p+1:end) = doDrawResiduals();
    iY = Y(:,:,iDraw);
    if any(any(isnan(iY(:,1:p))))
        nanInit(iDraw) = true;
    end
    if any(isnan(iBe(:)))
        nanResid(iDraw) = true;
    end
    for t = p+1 : nXPer
        iYInit = iY(:,t-(1:p));
        iY(:,t) = A*iYInit(:) + KJ(:,t) + iBe(:,t);
    end
    Y(:,:,iDraw) = iY;
    iE = iBe;
    if isIdentified
        iE = B\iE;
    end
    E(:,p+1:end,iDraw) = iE(:,p+1:end);
    % Update the progress bar.
    if opt.progress
        update(progress,iDraw/NDraw);
    end
end

% Report NaNs in initial conditions.
if any(nanInit)
    utils.warning('VAR:resample', ...
        'Some of the initial conditions for resampling are NaN %s.', ...
        preparser.alt2str(nanInit));
end

% Report NaNs in resampled residuals.
if any(nanResid)
    utils.warning('VAR:resample', ...
        'Some of the resampled residuals are NaN %s.', ...
        preparser.alt2str(nanResid));
end

% Return only endogenous variables, not shocks.
names = [This.YNames,This.ENames];
data = [Y;E];
if nx > 0
    names = [names,This.XNames];
    data = [data;x(:,:,ones(1,NDraw))];
end
Outp = myoutpdata(This,outpFmt,xRange,data,[],names);


% Nested functions...


%**************************************************************************

    
    function doChkMultipleParams()
        
        % Works only with single parameterisation and single group.
        if nAlt > 1
            utils.error('VAR:resample', ...
                ['Cannot resample from VAR objects ', ...
                'with multiple parameterisations.']);
        end
    end % doChkMultipleParams()


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
            u = allSampleE(:,iDraw);
            u = reshape(u,[ny,nXPer-p]);
            X = F*u;
        end
    end % doDrawResiduals()


end

