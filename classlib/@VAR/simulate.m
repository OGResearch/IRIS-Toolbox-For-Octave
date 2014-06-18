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
% paths into the contributions of individual residuals, initial condition,
% the constant, and exogenous inputs; see Description.
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
% Simulation of contributions
% ----------------------------
%
% With the option `'contributions=' true`, the output database contains
% Ne+2 columns for each variable, where Ne is the number of residuals. The
% first Ne columns are the contributions of the individual shocks, the
% (Ne+1)-th column is the contribution of initial condition and the
% constant, and the last, (Ne+2)-th columns is the contribution of
% exogenous inputs.
%
% Contribution simulations can be only run on VAR objects with one
% parameterization.
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

% Include pre-sample.
req = datarequest('y*,x*,e',This,Inp,Range,opt);
xRange = req.Range;
y = req.Y;
x = req.X;
e = req.E;
e(isnan(e)) = 0;

if ~isequal(req.Format,'dbase')
    utils.error('VAR:simulate', ...
        ['Only database (struct) is now a valid input data format in ', ...
        'VAR/simulate(...).']);
end

if isBackcast
    y = flip(y,2);
    e = flip(e,2);
    x = flip(x,2);
end

e(:,1:pp,:) = NaN;
nXPer = length(xRange);
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
        nLoop = ny + 2;
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
    x = zeros(nx,nXPer,nLoop);
end

if opt.contributions
    y(:,:,[1:end-2,end]) = 0;
    x(:,:,1:end-1) = 0;
end

if ~opt.contributions
    Outp = hdataobj(This,xRange,nLoop);
else
    Outp = hdataobj(This,xRange,nLoop,'Contributions=',@E);
end

% Main loop
%-----------

for iLoop = 1 : nLoop
    if iLoop <= nAlt
        [iA,iB,iK,iJ] = mysystem(This,iLoop);
    end

    isConst = ~opt.deviation;
    if opt.contributions
        if iLoop <= ny
            % Contributions of shocks.
            inx = true(1,ny);
            inx(iLoop) = false;
            e(inx,:,iLoop) = 0;
            isConst = false;
        elseif iLoop == ny+1
            % Contributions of init and const.
            e(:,:,iLoop) = 0;
            isConst = true;
        elseif iLoop == ny+2
            % Contributions of exogenous inputs.
            e(:,:,iLoop) = 0;
            isConst = false;
        end
    end
    
    iE = e(:,:,iLoop);
    if isempty(iB)
        iBe = iE;
    else
        iBe = iB*iE;
    end
    
    iY = y(:,:,iLoop);
    iX = [];
    if isX
        iX = x(:,:,iLoop);
    end

    % Collect deterministic terms (constant, exogenous inputs).
    iKJ = zeros(ny,nXPer);
    if isConst
        iKJ = iKJ + iK(:,ones(1,nXPer));
    end
    if isX
        iKJ = iKJ + iJ*iX;
    end
    
    for t = pp + 1 : nXPer
        iXLags = iY(:,t-(1:pp));
        iY(:,t) = iA*iXLags(:) + iKJ(:,t) + iBe(:,t);
    end
    
    if isBackcast
        iY = flip(iY,2);
        iE = flip(iE,2);
        if isX
            iX = flip(iX,2);
        end
    end

    % Assign current results.
    hdataassign(Outp,iLoop,iY,iX,iE,[]);
    
end

% Create output database.
Outp = hdata2tseries(Outp);

end
