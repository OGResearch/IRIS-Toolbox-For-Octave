function [This,Outp,DatFitted,Rr,Count] = estimate(This,Inp,varargin)
% estimate  Estimate a reduced-form VAR or BVAR.
%
% Syntax
% =======
%
%     [V,VData,Fitted] = estimate(V,Inp,Range,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - Empty VAR object.
%
% * `Inp` [ struct ] - Input database.
%
% * `Range` [ numeric ] - Estimation range, including `P` pre-sample
% periods, where `P` is the order of the VAR.
%
% Output arguments
% =================
%
% * `V` [ VAR ] - Estimated reduced-form VAR object.
%
% * `VData` [ struct ] - Output database with the endogenous
% variables and the estimated residuals.
%
% * `Fitted` [ numeric ] - Periods in which fitted values have been
% calculated.
%
% Options
% ========
%
% * `'A='` [ numeric | *empty* ] - Restrictions on the individual values in
% the transition matrix, `A`.
%
% * `'BVAR='` [ numeric ] - Prior dummy observations for estimating a BVAR;
% construct the dummy observations using the one of the `BVAR` functions.
%
% * `'C='` [ numeric | *empty* ] - Restrictions on the individual values in
% the constant vector, `C`.
%
% * `'diff='` [ `true` | *`false`* ] - Difference the series before
% estimating the VAR; integrate the series back afterwards.
%
% * `'G='` [ numeric | *empty* ] - Restrictions on the individual values in
% the matrix at the co-integrating vector, `G`.
%
% * `'cointeg='` [ numeric | *empty* ] - Co-integrating vectors (in rows)
% that will be imposed on the estimated VAR.
%
% * `'comment='` [ char | `Inf` ] - Assign comment to the estimated VAR
% object; `Inf` means the existing comment will be preserved.
%
% * `'constraints='` [ char ] - General linear constraints on the VAR
% parameters.
%
% * `'constant='` [ *`true`* | `false` ] - Include a constant vector in the
% VAR.
%
% * `'covParameters='` [ `true` | *`false`* ] - Calculate the covariance
% matrix of estimated parameters.
%
% * `'eqtnByEqtn='` [ `true` | *`false`* ] - Estimate the VAR equation by
% equation.
%
% * `'maxIter='` [ numeric | *`1`* ] - Maximum number of iterations when
% generalised least squares algorithm is involved.
%
% * `'mean='` [ numeric | *empty* ] - Impose a particular asymptotic mean
% on the VAR process.
%
% * `'order='` [ numeric | *`1`* ] - Order of the VAR.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the
% command window.
%
% * `'schur='` [ *`true`* | `false` ] - Calculate triangular (Schur)
% representation of the estimated VAR straight away.
%
% * `'stdize='` [ `true` | *`false`* ] - Adjust the prior dummy
% observations by the std dev of the observations.
%
% * `'timeWeights=`' [ tseries | empty ] - Time series of weights applied
% to individual periods in the estimation range.
%
% * `'tolerance='` [ numeric | *`1e-5`* ] - Convergence tolerance when
% generalised least squares algorithm is involved.
%
% * `'yNames='` [ cellstr | function_handle | *`@(n) sprintf('y%g',n)`* ] -
% Use these names for the VAR variables.
%
% * `'eNames='` [ cellstr | function_handle | *`@(yname,n) ['res_',yname]`*
% ] - Use these names for the VAR residuals.
%
% * `'warning='` [ *`true`* | `false` ] - Display warnings produced by this
% function.
%
% Options for panel VAR
% ======================
%
% * `'fixedEffect='` [ `true` | *`false`* ] - Include constant dummies for
% fixed effect in panel estimation; applies only if `'constant=' true`.
%
% * `'groupWeights='` [ numeric | *empty* ] - A 1-by-NGrp vector of weights
% applied to groups in panel estimation, where NGrp is the number of
% groups; the weights will be rescaled so as to sum up to `1`.
%
% Description
% ============
%
% Estimating a panel VAR
% -----------------------
%
% Panel VAR objects are created by calling the function [`VAR`](VAR/VAR)
% with two input arguments: the list of variables, and the list of group
% names. To estimate a panel VAR, the input data, `Inp`, must be organised
% a super-database with sub-databases for each group, and time series for
% each variables within each group:
%
%     d.Group1_Name.Var1_Name
%     d.Group1_Name.Var2_Name
%     ...
%     d.Group2_Name.Var1_Name
%     d.Group2_Name.Var2_Name
%     ...
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('V',@(x) isa(x,'VAR'));
pp.addRequired('Inp',@(x) myisvalidinpdata(This,x));
pp.parse(This,Inp);

% Get input data; the user range is supposed to INCLUDE the pre-sample
% initial condition.
[y,xRange,Ynames,inpFmt,varargin] = myinpdata(This,Inp,varargin{:});

% Pass and validate options.
opt = passvalopt([class(This),'.estimate'],varargin{:});

if strcmpi(opt.output,'auto')
    outpFmt = inpFmt;
else
    outpFmt = opt.output;
end

if ~isempty(opt.cointeg)
    opt.diff = true;
end

% Create components of the LHS and RHS data. Panel VARs create data by
% concatenting individual groups next to each other separated by a total of
% p NaNs.
[y0,k0,y1,g1,ci] = mystackdata(This,y,opt);

%--------------------------------------------------------------------------

This.range = xRange;
nXPer = length(This.range);

ng = size(g1,1);
nk = size(k0,1);
ny = size(y0,1);
nObs = size(y0,2);
p = opt.order;
nData = size(y0,3);

%{
% TODO: Remove this.
% All data sets must have the same structure of missing observations.
if nData > 1
    nanInx = isnan(y);
    allNan = all(nanInx,3);
    anyNan = any(nanInx,3);
    if any(anyNan & ~allNan)
        utils.error('VAR', ...
            ['All data sets must have the same structure ', ...
            'of missing observations.']);
    end
end
%}

if ~isempty(opt.mean)
    if length(opt.mean) == 1
        opt.mean = opt.mean(ones(ny,1));
    else
        opt.mean = opt.mean(:);
    end
end

if ~isempty(opt.mean)
    opt.constant = false;
end

% Read parameter restrictions, and set up their hyperparameter form.
% They are organised as follows:
% * Rr = [R,r],
% * beta = R*gamma + r.
This.Rr = VAR.restrict(ny,nk,ng,opt);

% Get the number of hyperparameters.
if isempty(This.Rr)
    % Unrestricted VAR.
    if ~opt.diff
        % Level VAR.
        This.nhyper = ny*(nk+p*ny+ng);
    else
        % Difference VAR or VEC.
        This.nhyper = ny*(nk+(p-1)*ny+ng);
    end
else
    % Parameter restrictions in the hyperparameter form:
    % beta = R*gamma + r;
    % The number of hyperparams is given by the number of columns of R.
    % The Rr matrix is [R,r], so we need to subtract 1.
    This.nhyper = size(This.Rr,2) - 1;
end

% Number of priors.
nPrior = size(opt.bvar,3);

% Total number of cycles.
nLoop = max([nData,nPrior]);

% Estimate reduced-form VAR parameters. The size of coefficient matrices
% will always be determined by p whether this is a~level VAR or
% a~difference VAR.
resid = nan(ny,nObs,nLoop);
DatFitted = cell(1,nLoop);
Count = zeros(1,nLoop);

% Pre-allocate VAR matrices.
This = myprealloc(This,ny,p,ng,nXPer,nLoop);

% Create command-window progress bar.
if opt.progress
    progress = progressbar('IRIS VAR.estimate progress');
end

% Main loop
%-----------
ss = struct();
ss.Rr = This.Rr;
ss.k0 = k0;
ss.ci = ci;
% Weighted GLSQ; the function is different for VARs and PVARs, becuase
% PVARS possibly combine weights on time periods and weights on groups.
ss.w = myglsqweights(This,opt);

for iLoop = 1 : nLoop
    ss.y0 = y0(:,:,min(iLoop,end));
    ss.y1 = y1(:,:,min(iLoop,end));
    ss.g1 = g1(:,:,min(iLoop,end));
    
    % Run generalised least squares. Assign the individual properties computed
    % within `VAR.myglsq()` in a separate set of assignments to help trace down
    % run-time errors.
    ss = VAR.myglsq(ss,opt);
    
    This.A(:,:,iLoop) = ss.A;
    This.G(:,:,iLoop) = ss.G;
    This.Omega(:,:,iLoop) = ss.Omg;
    This.Sigma(:,:,iLoop) = ss.Sgm;
    resid(:,:,iLoop) = ss.resid;

    if size(ss.K,2) == size(This.K,2)
        This.K(:,:,iLoop) = ss.K;
    else
        This.K(:,:,iLoop) = ss.K(:,ones(1,size(This.K,2)));
    end
    
    [This,fitted,DatFitted{iLoop}] = myfitted(This,ss.resid);
    This.fitted(:,:,iLoop) = fitted;
    Count(iLoop) = ss.count;

    if opt.progress
        update(progress,iLoop/nLoop);
    end
    
end

% Calculate triangular representation.
if opt.schur
    This = schur(This);
end

% Populate information criteria AIC and SBC.
This = infocrit(This);

% Expand the output data to match the size of residuals if necessary.
if size(y,3) < nLoop
    n = size(y,3);
    y(:,:,end+1:nLoop) = y(:,:,end*ones(1,n));
end

% Report observations that could not be fitted.
doChkObsNotFitted();

% Set names of variables and residuals.
doNames();

if nargout > 1
    doOutpData();
end

if nargout > 2
    Rr = This.Rr;
end

if ~isequal(opt.comment,Inf)
    This = comment(This,opt.comment);
end

% Nested functions.

%**************************************************************************
    function doChkObsNotFitted()
        allFitted = all(all(This.fitted,1),3);
        if opt.warning && any(~allFitted(p+1:end))
            missing = This.range(p+1:end);
            missing = missing(~allFitted(p+1:end));
            [~,consec] = datconsecutive(missing);
            utils.warning('VAR', ...
                ['The following period(s) not fitted ', ...
                'because of missing observations: %s.'], ...
                consec{:});
        end
    end % doChkObsNotFitted().

%**************************************************************************
    function doNames()
        if isempty(Ynames)
            if length(opt.ynames) == ny
                Ynames = opt.ynames;
            else
                Ynames = This.Ynames;
            end
        end
        if ~isempty(opt.enames)
            Enames = opt.enames;
        else
            Enames = This.Enames;
        end
        This = myynames(This,Ynames);
        This = myenames(This,Enames);
    end % doNames().

%**************************************************************************
    function doOutpData()
        if ispanel(This)
            % Panel VAR.
            nGrp = length(This.GroupNames);
            Outp = struct();
            for iiGrp = 1 : nGrp
                name = This.GroupNames{iiGrp};
                iY0 = y0(:,1:nXPer,:);
                iResid = resid(:,1:nXPer,:);
                Outp.(name) = myoutpdata(This,'dbase',This.range, ...
                    [iY0;iResid],[],[This.Ynames,This.Enames]);
                y0(:,1:nXPer+p,:) = [];
                resid(:,1:nXPer+p,:) = [];
            end
        else
            % Non-panel VAR.
            y0 = y0(:,1:nXPer);
            resid = resid(:,1:nXPer);
            Outp = myoutpdata(This,outpFmt,This.range, ...
                [y0;resid],[],[This.Ynames,This.Enames]);
        end
    end % doOutpData().

end