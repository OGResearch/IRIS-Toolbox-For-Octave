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
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Parse input arguments.
pp = inputParser();
pp.addRequired('V',@(x) isa(x,'VAR'));
pp.addRequired('Inp',@(x) myisvalidinpdata(This,x));
pp.addRequired('Range',@(x) isnumeric(x) && ~any(isinf(x(:))));
pp.parse(This,Inp,Range);

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
nx = length(This.XNames);
isX = nx > 0;

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

req = datarequest('y*,x*,e',This,Inp,Range,opt);
outpFmt = req.Format;
Range = req.Range;
y = req.Y;
x = req.X;
e = req.E;
e(isnan(e)) = 0;

if isBackcast
    y = flip(y,2);
    e = flip(e,2);
    x = flip(x,2);
end

e(:,1:pp,:) = NaN;
nPer = length(Range);
nDataY = size(y,3);
nDataX = size(x,3);
nDataE = size(e,3);
nLoop = max([nAlt,nDataY,nDataX,nDataE]);

if opt.contributions
    if nLoop > 1
        % Cannot run contributions for multiple data sets or params.
        utils.error('model','#Cannot_simulate_contributions');
    else
        % Simulation of contributions.
        nLoop = ny + 1;
    end
end

% Expand Y, E, X data in 3rd dimension to match nLoop.
if nDataY < nLoop
    y = cat(3,y,y(:,:,end*ones(1,nLoop-nDataY)));
end
if nDataE < nLoop
    e = cat(3,e,e(:,:,end*ones(1,nLoop-nDataE)));
end
if isX && nDataX < nLoop
    x = cat(3,x,x(:,:,end*ones(1,nLoop-nDataX)));
elseif ~isX
    x = zeros(nx,nPer,nLoop);
end

for iLoop = 1 : nLoop
    if iLoop <= nAlt
        [iA,iB,iK,iJ] = mysystem(This,iLoop);
    end

    isConst = ~opt.deviation;
    if opt.contributions
        if iLoop <= ny
            inx = true(1,ny);
            inx(iLoop) = false;
            e(inx,:,iLoop) = 0;
            y(:,1:pp,iLoop) = 0;
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
    
    iY = y(:,:,iLoop);
    if isX
        iX = x(:,:,iLoop);
    end

    % Collect deterministic terms (constant, exogenous inputs).
    iKJ = zeros(ny,nPer);
    if isConst
        iKJ = iKJ + iK(:,ones(1,nPer));
    end
    if isX
        iKJ = iKJ + iJ*iX;
    end
    
    for t = pp + 1 : nPer
        iXLags = iY(:,t-(1:pp));
        iY(:,t) = iA*iXLags(:) + iKJ(:,t) + iBe(:,t);
    end
    y(:,:,iLoop) = iY;
end

if isBackcast
    y = flip(y,2);
    e = flip(e,2);
    x = flip(x,2);
end

names = [This.YNames,This.XNames];
data = [y;x];
if opt.returnresiduals
    names = [names,This.ENames];
    data = [data;e];
end

% Output data.
Outp = myoutpdata(This,outpFmt,Range,data,[],names);

% Contributions comments.
if opt.contributions && strcmp(outpFmt,'dbase')
    contList = [This.ENames,{'Init+Const'}];
    for i = 1 : length(names)
        c = utils.concomment(names{i},contList);
        Outp.(names{i}) = comment(Outp.(names{i}),c);
    end
end

end
