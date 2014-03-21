function Outp = forecast(This,Inp,Range,varargin)
% forecast  Unconditional or conditional VAR forecasts.
%
% Syntax
% =======
%
%     Outp = forecast(V,Inp,Range,...)
%     Outp = forecast(V,Inp,Range,Cond,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% * `Inp` [ struct ] - Input database from which initial condition will be
% read.
%
% * `Range` [ numeric ] - Forecast range; must not refer to `Inf`.
%
% * `Cond` [ struct | tseries ] - Conditioning database with the mean
% values of residuals, reduced-form conditions on endogenous variables, and
% conditioning instruments.
%
% Output arguments
% =================
%
% * `Outp` [ struct ] - Output database with forecasts of endogenous
% variables, residuals, and conditioning instruments.
%
% Options
% ========
%
% * `'cross='` [ numeric | *`1`* ] - Multiply the off-diagonal elements of
% the covariance matrix (cross-covariances) by this factor; `'cross='` must
% be equal to or smaller than `1`.
%
% * `'dbOverlay='` [ `true` | *`false`* ] - Combine the output data with the
% input data; works only if the input data is a database.
%
% * `'deviation='` [ `true` | *`false`* ] - Both input and output data are
% deviations from the unconditional mean.
%
% * `'meanOnly='` [ `true` | *`false`* ] - Return a plain database with mean
% forecasts only.
%
% * `'omega='` [ numeric | *empty* ] - Modify the covariance matrix of
% residuals for this forecast.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

JData = [];
if ~isempty(varargin) && ~ischar(varargin{1})
    JData = varargin{1};
    varargin(1) = [];
end

% Parse input arguments.
pp = inputParser();
if ismatlab
pp.addRequired('V',@(isArg)is.VAR(isArg));
pp.addRequired('Inp',@(x) myisvalidinpdata(This,x));
pp.addRequired('Range',@(x) isnumeric(x) && ~any(isinf(x(:))));
pp.addRequired('Cond',@(x) myisvalidinpdata(This,x));
pp.parse(This,Inp,Range,JData);
else
pp = pp.addRequired('V',@(isArg)is.VAR(isArg));
pp = pp.addRequired('Inp',@(x) myisvalidinpdata(This,x));
pp = pp.addRequired('Range',@(x) isnumeric(x) && ~any(isinf(x(:))));
pp = pp.addRequired('Cond',@(x) myisvalidinpdata(This,x));
pp = pp.parse(This,Inp,Range,JData);
end

% Panel VAR.
if ispanel(This)
    Outp = mygroupmethod(@forecast,This,Inp,Range,varargin{:});
    return
end

% Parse options.
opt = passvalopt('VAR.forecast',varargin{1:end});

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);
ni = size(This.Zi,1);

if isempty(Range)
    utils.warning('VAR','Forecast range is empty.');
    if opt.meanonly
        Inp = [];
    else
        Inp = struct();
        Inp.mean = [];
        Inp.std = [];
    end
end

if (Range(1) > Range(end))
    % Go backward in time.
    backcast = true;
    This = backward(This);
    xRange = Range(end) : Range(1)+p;
    Range = Range(end) : Range(1);
else
    backcast = false;
    xRange = Range(1)-p : Range(end);
end

% Include pre-sample.
[outpFmt,xRange,y,e] = mydatarequest(This,Inp,xRange,opt);
e(isnan(e)) = 0;

nPer = length(Range);
nXPer = length(xRange);

% Get tunes on VAR variables and instruments; do not include pre-sample.
[~,~,jy,~,ji] = mydatarequest(This,JData,Range);
if backcast
    y = y(:,end:-1:1,:,:);
    e = e(:,end:-1:1,:,:);
    jy = jy(:,end:-1:1,:,:);
    ji = ji(:,end:-1:1,:,:);
end

x0 = y(:,1:p,:);
e = e(:,p+1:end,:);

nData = size(x0,3);
nCond = size(jy,3);
nInst = size(ji,3);
nOmg = size(opt.omega,3);

nLoop = max([nAlt,nData,nCond,nInst,nOmg]);

retInstruments = ni > 0 && opt.returninstruments;
retResiduals = opt.returnresiduals;

% Stack initial conditions.
x0 = x0(:,p:-1:1,:);
x0 = reshape(x0(:),ny*p,size(x0,3));

Y = nan(ny,nXPer,nLoop);
E = nan(ny,nXPer,nLoop);
P = zeros(ny,ny,nXPer,nLoop);
if retInstruments
    I = nan(ni,nXPer,nLoop);
end

Zi = This.Zi;
if isempty(Zi)
    Zi = zeros(0,1+ny*p);
end

s = struct();
s.invFunc = @inv;
s.allObs = NaN;
s.tol = 0;
s.reuse = false;
s.ahead = 1;

for iLoop = 1 : nLoop
    
    [iA,iB,iK,iOmg] = mysystem(This,iLoop);
    
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
    
    % Use the `allObserved` option in `varsmoother` only if the cov matrix is
    % full rank. Otherwise, there is singularity.
    s.allObs = rank(iOmg) == ny;

    % Get the iLoop-th data.
    ix0 = x0(:,min(iLoop,end));
    ie = e(:,:,min(iLoop,end));
    ijy = jy(:,:,min(iLoop,end));
    
    if retInstruments
        jii = ji(:,:,min(iLoop,end));
        Cii = Zi(:,1);
        Zii = Zi(:,2:end);
    else
        jii = zeros(0,nPer);
        Cii = zeros(0,1);
        Zii = zeros(0,ny*p);
    end
    
    if ~isempty(jii)
        Z = [eye(ny,ny*p);Zii];
        D = [zeros(ny,1);Cii];
        s.allObs = false;
    else
        Z = eye(ny);
        D = [];
    end
    
    % Run Kalman filter and smoother.
    [~,~,iE,~,iY,iP] = ...
        timedom.varsmoother(iA,iB,iK,Z,D,iOmg,0,[ijy;jii],ie,ix0,0,s);
    
    E(:,p+1:end,iLoop) = iE;
    % Add pre-sample initial condition.
    Y(:,p:-1:1,iLoop) = reshape(ix0,ny,p);
    % Add forecast data; `iY` includes both the VAR variables and the
    % instruments.
    Y(:,p+1:end,iLoop) = iY(1:ny,:);
    P(:,:,p+1:end,iLoop) = iP(1:ny,1:ny,:);
    % Evaluate conditioning instruments.
    if retInstruments
        I(:,p+1:end,iLoop) = iY(ny+1:end,:);
    end
end

if backcast
    Y = Y(:,end:-1:1,:);
    E = E(:,end:-1:1,:);
    if retInstruments
        I = I(:,end:-1:1,:);
    end
    P = P(:,:,end:-1:1,:);
end

% Prepare output data.
names = This.Ynames;
if retResiduals
    Y = [Y;E];
    names = [names,This.Enames];
end
if retInstruments
    Y = [Y;I];
    names = [names,This.inames];
end

% Output data for endougenous variables, residuals, and instruments.
if opt.meanonly
    Outp = myoutpdata(This,outpFmt,xRange,Y,[],names);
    if strcmp(outpFmt,'dbase') && opt.dboverlay
        if ~isfield(Inp,'mean')
            Outp = dboverlay(Inp,Outp);
        else
            Outp = dboverlay(Inp.mean,Outp);
        end
    end
else
    Outp = myoutpdata(This,outpFmt,xRange,Y,P,names);
    if strcmp(outpFmt,'dbase') && opt.dboverlay
        if ~isfield(Inp,'mean')
            Outp.mean = dboverlay(Inp,Outp.mean);
        else
            Outp.mean = dboverlay(Inp.mean,Outp.mean);
        end
    end    
end

end