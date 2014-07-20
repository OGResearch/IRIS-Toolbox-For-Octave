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
% * `'J='` [ numeric | *empty* ] - Restrictions on the individual values in
% the coefficient matrix in front of exogenous inputs, `J`.
%
% * `'diff='` [ `true` | *`false`* ] - Difference the series before
% estimating the VAR; integrate the series back afterwards.
%
% * `'G='` [ numeric | *empty* ] - Restrictions on the individual values in
% the coefficient matrix in front of the co-integrating vector, `G`.
%
% * `'cointeg='` [ numeric | *empty* ] - Co-integrating vectors (in rows)
% that will be imposed on the estimated VAR.
%
% * `'comment='` [ char | `Inf` ] - Assign comment to the estimated VAR
% object; `Inf` means the existing comment will be preserved.
%
% * `'constraints='` [ char | cellstr ] - General linear constraints on the
% VAR parameters.
%
% * `'constant='` [ *`true`* | `false` ] - Include a constant vector in the
% VAR.
%
% * `'covParam='` [ `true` | *`false`* ] - Calculate and store the
% covariance matrix of estimated parameters.
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
% * `'warning='` [ *`true`* | `false` ] - Display warnings produced by this
% function.
%
% Options for panel VAR
% ======================
%
% * `'fixedEff='` [ `true` | *`false`* ] - Include constant dummies for
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
% -Copyright (c) 2007-2014 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('Inp',@(x) myisvalidinpdata(This,x));
pp.parse(Inp);

% Get input data; the user range is supposed to **include** the pre-sample
% initial condition.
[y,x,xRange,yNames,inpFmt,varargin] = myinpdata(This,Inp,varargin{:});

% Pass and validate options.
opt = passvalopt('VAR.estimate',varargin{:});

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
[y0,k0,x0,y1,g1,ci] = mystackdata(This,y,x,opt);

%--------------------------------------------------------------------------

This.Range = xRange;
nXPer = length(xRange);

ng = size(g1,1);
nk = size(k0,1);
ny = size(y0,1);
nx = size(x0,1);
nObs = size(y0,2);
p = opt.order;
nData = size(y0,3);
nGrp = max(1,length(This.GroupNames));

if ny == 0
    utils.error('VAR:estimate', ...
        'Cannot estimate VAR object with no variables.');
end

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
This.Rr = VAR.restrict(ny,nk,nx,ng,opt);

% Get the number of hyperparameters.
if isempty(This.Rr)
    % Unrestricted VAR.
    if ~opt.diff
        % Level VAR.
        This.NHyper = ny*(nk+nx+p*ny+ng);
    else
        % Difference VAR or VEC.
        This.NHyper = ny*(nk+nx+(p-1)*ny+ng);
    end
else
    % Parameter restrictions in the hyperparameter form:
    % beta = R*gamma + r;
    % The number of hyperparams is given by the number of columns of R.
    % The Rr matrix is [R,r], so we need to subtract 1.
    This.NHyper = size(This.Rr,2) - 1;
end

nLoop = nData;

% Estimate reduced-form VAR parameters. The size of coefficient matrices
% will always be determined by p whether this is a~level VAR or
% a~difference VAR.
resid = nan(ny,nObs,nLoop);
DatFitted = cell(1,nLoop);
Count = zeros(1,nLoop);

% Pre-allocate VAR matrices.
This = myprealloc(This,ny,p,nXPer,nLoop,ng);

% Create command-window progress bar.
if opt.progress
    progress = progressbar('IRIS VAR.estimate progress');
end

% Main loop
%-----------
s = struct();
s.Rr = This.Rr;
s.ci = ci;
s.order = p;
% Weighted GLSQ; the function is different for VARs and panel VARs, becuase
% Panel VARs possibly combine weights on time periods and weights on groups.
s.w = myglsqweights(This,opt);

for iLoop = 1 : nLoop
    s.y0 = y0(:,:,min(iLoop,end));
    s.y1 = y1(:,:,min(iLoop,end));
    s.k0 = k0(:,:,min(iLoop,end));
    s.x0 = x0(:,:,min(iLoop,end));
    s.g1 = g1(:,:,min(iLoop,end));
    
    % Run generalised least squares.
    s = VAR.myglsq(s,opt);

    % Assign estimated coefficient matrices to the VAR object.
    [This,DatFitted{iLoop}] = myassignest(This,s,iLoop,opt);
    
    resid(:,:,iLoop) = s.resid;
    Count(iLoop) = s.count;

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
n = size(y0,3);
if n < nLoop
    y0(:,:,end+1:nLoop) = y0(:,:,end*ones(1,n-nLoop));
    if nx > 0
        x0(:,:,end+1:nLoop) = x0(:,:,end*ones(1,n-nLoop));
    end
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


% Nested functions...


%**************************************************************************


    function doChkObsNotFitted()
        allFitted = all(all(This.Fitted,1),3);
        if opt.warning && any(~allFitted(p+1:end))
            missing = This.Range(p+1:end);
            missing = missing(~allFitted(p+1:end));
            [~,consec] = datconsecutive(missing);
            utils.warning('VAR', ...
                ['The following period(s) not fitted ', ...
                'because of missing observations: %s.'], ...
                consec{:});
        end
    end % doChkObsNotFitted()


%**************************************************************************


    function doNames()
        if isempty(yNames)
            if length(opt.ynames) == ny
                % ##### Nov 2013 OBSOLETE and scheduled for removal.
                utils.warning('obsolete', ...
                    ['This syntax for specifying variable names is obsolete ', ...
                    'and will be removed from a future version of IRIS. ', ...
                    'Specify variable names at the time of creating ', ...
                    '%s objects instead.'], ...
                    class(This));
                yNames = opt.ynames;
            else
                yNames = This.YNames;
            end
        end
        eNames = This.ENames;
        This = myynames(This,yNames);
        This = myenames(This,eNames);
    end % doNames()


%**************************************************************************


    function doOutpData()
        yxeNames = [This.YNames,This.XNames,This.ENames];
        yxe = [y0;x0;resid];
        if ispanel(This)
            % Panel VAR.
            nGrp = length(This.GroupNames);
            Outp = struct();
            for iiGrp = 1 : nGrp
                name = This.GroupNames{iiGrp};
                Outp.(name) = myoutpdata(This,'dbase',This.Range, ...
                    yxe(:,1:nXPer,:),[],yxeNames);
                yxe(:,1:nXPer+p,:) = [];
            end
        else
            % Non-panel VAR.
            Outp = myoutpdata(This,outpFmt,This.Range, ...
                yxe(:,1:nXPer,:),[],yxeNames);
        end
    end % doOutpData()


end
