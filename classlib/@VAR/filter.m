function [This,Outp] = filter(This,Inp,Range,varargin)
% filter  Filter data using a VAR model.
%
% Syntax
% =======
%
%     [V,Outp] = filter(V,Inp,Range,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - Input VAR object.
%
% * `Inp` [ struct ] - Input database from which initial condition will be
% read.
%
% * `Range` [ numeric ] - Forecast range.
%
% Output arguments
% =================
%
% * `V` [ VAR ] - Output VAR object.
%
% * `Outp` [ struct ] - Output database with prediction and/or smoothed
% data.
%
% Options
% ========
%
% * `'cross='` [ numeric | *`1`* ] - Multiply the off-diagonal elements of
% the covariance matrix (cross-covariances) by this factor; `'cross='` must
% be equal to or smaller than `1`.
%
% * `'deviation='` [ `true` | *`false`* ] - Both input and output data are
% deviations from the unconditional mean.
%
% * `'meanOnly='` [ `true` | *`false`* ] - Return a plain database with mean
% forecasts only.
%
% * `'omega='` [ numeric | *empty* ] - Modify the covariance matrix of
% residuals for this run of the filter.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Parse input arguments.
pp = inputParser();
pp = pp.addRequired('V',@isvar);
pp = pp.addRequired('Inp',@(x) isstruct(x));
pp = pp.addRequired('Range',@isnumeric);
pp = pp.parse(This,Inp,Range);

% Parse options.
opt = passvalopt('VAR.filter',varargin{1:end});

if isequal(Range,Inf)
    utils.error('VAR', ...
        'Cannot use Inf for range in VAR/filter().');
end

isSmooth = ~isempty(strfind(opt.output,'smooth'));
isPred = ~isempty(strfind(opt.output,'pred'));

% TODO: Filter.
isFilter = false; % ~isempty(strfind(opt.output,'filter'));

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

Range = Range(1) : Range(end);
xRange = Range(1)-p : Range(end);

% Include pre-sample.
[~,xRange,y] = mydatarequest(This,Inp,xRange,opt);
% e(isnan(e)) = 0;

nPer = length(Range);
nXPer = length(xRange);
xInit = y(:,1:p,:);
y = y(:,p+1:end,:);

nData = size(xInit,3);
nOmg = size(opt.omega,3);

nLoop = max([nAlt,nData,nOmg]);
doChkOptions();

% Stack initial conditions.
xInit = xInit(:,p:-1:1,:);
xInit = reshape(xInit(:),ny*p,nLoop);

YY = [];
doRequestOutp();

s = struct();
s.invFunc = @inv;
s.allObs = NaN;
s.tol = 0;
s.reuse = 0;
s.ahead = opt.ahead;

Z = eye(ny);
for iLoop = 1 : nLoop
    
    [iA,iB,iK,iOmg] = mysystem(This,iLoop);
    
    % User-supplied covariance matrix.
    if ~isempty(opt.omega)
        iOmg(:,:) = opt.omega(:,:,min(iLoop,end));
    end
    
    % Remove the constant vector if this is a deviation simulation.
    if opt.deviation
        iK = [];
    end
    % Reduce or zero off-diagonal elements in the cov matrix of residuals
    % if requested. This only matters in VARs, not SVARs.
    if double(opt.cross) < 1
        inx = logical(eye(size(iOmg)));
        iOmg(~inx) = double(opt.cross)*iOmg(~inx);
    end

    % Use the `allobserved` option in `varsmoother` only if the cov matrix is
    % full rank. Otherwise, there is singularity.
    s.allObs = rank(iOmg) == ny;
    
    iY = y(:,:,min(iLoop,end));
    iXInit = xInit(:,:,min(iLoop,end));
    
    % Run Kalman filter and smoother.
    [~,~,iE2,~,iY2,iPy2,~,iY0,iPy0,iY1,iPy1] = timedom.varsmoother( ...
        iA,iB,iK,Z,[],iOmg,[],iY,[],iXInit,0,s);
    
    % Add pre-sample periods and assign hdata.
    doAssignOutp();
    
end

% Final output database.
Outp = hdataobj.hdatafinal(YY,This,xRange);

% Nested fuctions.

%**************************************************************************
    function doChkOptions()
        if nLoop > 1 && opt.ahead > 1
            utils.error('VAR', ...
                ['Cannot run filter() with option ``ahead=`` greater than 1 ', ...
                'on multiple parameterisations or multiple data sets.']);
        end
        if ~isPred
            opt.ahead = 1;
        end
    end % doChkOptions().

%**************************************************************************
    function doRequestOutp()
        if isSmooth
            YY.smoothmean = hdataobj(This,[],nXPer,nLoop);
            if ~opt.meanonly
                YY.smoothstd = hdataobj(This,struct('IsStd',true), ...
                    nXPer,nLoop);
            end
        end
        if isPred
            YY.predmean = hdataobj(This,[],nXPer,nLoop);
            if ~opt.meanonly
                YY.predstd = hdataobj(This,struct('IsStd',true), ...
                    nXPer,nLoop);
            end
        end
        if isFilter
            YY.filtermean = hdataobj(This,[],nXPer,nLoop);
            if ~opt.meanonly
                YY.filterstd = hdataobj(This,struct('IsStd',true), ...
                    nXPer,nLoop);
            end
        end
    end % doRequestOutp().

%**************************************************************************
    function doAssignOutp()
        if isSmooth
            iY2 = [nan(ny,p),iY2];
            iY2(:,p:-1:1) = reshape(iXInit,ny,p);
            iE2 = [nan(ny,p),iE2];
            hdataassign(YY.smoothmean,This,iLoop, ...
                iY2,[],iE2);
            if ~opt.meanonly
                iD2 = covfun.cov2var(iPy2);
                iD2 = [zeros(ny,p),iD2];
                hdataassign(YY.smoothstd,This,iLoop,iD2,[],nan(ny,nXPer));
            end
        end
        if isPred
            iY0 = [nan(ny,p,s.ahead),iY0];
            iE0 = [nan(ny,p,s.ahead),zeros(ny,nPer,s.ahead)];
            if s.ahead > 1
                pos = 1 : s.ahead;
            else
                pos = iLoop;
            end
            hdataassign(YY.predmean,This,pos, ...
                iY0,[],iE0);
            if ~opt.meanonly
                iD0 = covfun.cov2var(iPy0);
                iD0 = [zeros(ny,p),iD0];
                hdataassign(YY.predstd,This,iLoop,iD0,[],[]);
            end
        end
        if isFilter
            iY1 = [nan(ny,p,s.ahead),iY1];
            iE1 = [nan(ny,p,s.ahead),zeros(ny,nPer,s.ahead)];
            hdataassign(YY.filtermean,This,pos, ...
                iY1,[],iE1);
            if ~opt.meanonly
                iD1 = covfun.cov2var(iPy1);
                iD1 = [zeros(ny,p),iD1];
                hdataassign(YY.filterstd,This,iLoop,iD1,[],[]);
            end
        end
    end % doAssignOutp().

end