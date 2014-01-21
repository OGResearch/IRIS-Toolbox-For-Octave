function Outp = simulate(This,Inp,Range,varargin)
% simulate  Simulate VAR model.
%
% Syntax
% =======
%
%     Outp = simulate(V,Inp,Range,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object that will be simulated.
%
% * `Inp` [ tseries | struct ] - Input data from which the initial
% condtions and residuals will be taken.
%
% * `Range` [ numeric ] - Simulation range; must not refer to `Inf`.
%
% Output arguments
% =================
%
% * `Outp` [ tseries ] - Simulated output data.
%
% Options
% ========
%
% * `'contributions='` [ `true` | *`false`* ] - Decompose the simulated
% paths into contributions of individual residuals.
%
% * `'deviation='` [ `true` | *`false`* ] - Treat input and output data as
% deviations from unconditional mean.
%
% * `'output='` [ *`'auto'`* | `'dbase'` | `'tseries'` ] - Format of output
% data.
%
% Description
% ============
%
% Backward simulation (backcast)
% ------------------------------
%
% If the `Range` is a vector of decreasing dates, the simulation is
% performed backward. The VAR object is first converted to its backward
% representation using the function [`backward`](VAR/backward), and then
% the data are simulated from the latest date to the earliest date.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Parse input arguments.
pp = inputParser();
pp = pp.addRequired('V',@(x) isa(x,'VAR'));
pp = pp.addRequired('Inp',@(x) myisvalidinpdata(This,x));
pp = pp.addRequired('Range',@(x) isnumeric(x) && ~any(isinf(x(:))));
pp = pp.parse(This,Inp,Range);

% Panel VAR.
if ispanel(This)
    Outp = mygroupmethod(@simulate,This,Inp,Range,varargin{:});
    return
end

% Parse options.
opt = passvalopt('VAR.simulate',varargin{1:end});

%--------------------------------------------------------------------------

ny = size(This.A,1);
pp = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

if isempty(Range)
    return
end

isBackcast = Range(1) > Range(end);
if isBackcast
    This = backward(This);
    Range = Range(end) : Range(1)+pp;
else
    Range = Range(1)-pp : Range(end);
end

[outpFmt,Range,x,e] = mydatarequest(This,Inp,Range,opt);
e(isnan(e)) = 0;

if isBackcast
    x = x(:,end:-1:1,:,:);
    e = e(:,end:-1:1,:,:);
end

e(:,1:pp,:) = NaN;
nPer = length(Range);
nData = size(x,3);
nLoop = max([nAlt,nData]);

if opt.contributions
    if nLoop > 1
        % Cannot run contributions for multiple data sets or params.
        utils.error('model','#Cannot_simulate_contributions');
    else
        % Simulation of contributions.
        nLoop = ny + 1;
    end
end

if nData < nLoop
    expand = ones(1,nLoop-nData);
    x = cat(3,x,x(:,:,end*expand));
    e = cat(3,e,e(:,:,end*expand));
end

for iLoop = 1 : nLoop
    if iLoop <= nAlt
        [iA,iB,iK] = mysystem(This,iLoop);
    end
    isConst = ~opt.deviation;
    if opt.contributions
        if iLoop <= ny
            inx = true(1,ny);
            inx(iLoop) = false;
            e(inx,:,iLoop) = 0;
            x(:,1:pp,iLoop) = 0;
            isConst = false;
        else
            e(:,:,iLoop) = 0;
        end
    end
    if isempty(iB)
        iBe = e(:,:,iLoop);
    else
        iBe = iB*e(:,:,iLoop);
    end
    iX = x(:,:,iLoop);
    for t = pp + 1 : nPer
        iXLags = iX(:,t-(1:pp));
        iX(:,t) = iA*iXLags(:) + iBe(:,t);
        if isConst
            iX(:,t) = iX(:,t) + iK;
        end
    end
    x(:,:,iLoop) = iX;
end

if isBackcast
    x = x(:,end:-1:1,:,:);
    e = e(:,end:-1:1,:,:);
end

names = This.Ynames;
if opt.returnresiduals
    names = [names,This.Enames];
else
    e = [];
end

% Output data.
Outp = myoutpdata(This,outpFmt,Range,[x;e],[],names);

end
