function [S,FF,AA] = shockplot(This,ShockName,SimRange,PlotList,varargin)
% shockplot  Short-cut for running and plotting plain shock simulation.
%
% Syntax
% =======
%
%     [S,FF,AA] = shockplot(M,ShockName,SimRange,PlotList,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object that will be simulated.
%
% * `ShockName` [ char ] - Name of the shock that will be simulated.
%
% * `SimRange` [ numeric ] - Date range on which the shock will be
% simulated.
%
% * `PlotList` [ cellstr ] - List of variables that will be reported; you
% can use the syntax of [`dbase/dbplot`](dbase/dbplot).
%
% Output arguments
% =================
%
% * `S` [ struct ] - Database with simulation results.
%
% * `FF` [ numeric ] - Handles of figure windows created.
%
% * `AA` [ numeric ] - Handles of axes objects created.
%
% Options affecting the simulation
% =================================
%
% * `'deviation='` [ *`true`* | `false` ] - See the option `'deviation='`
% in [`model/simulate`](model/simulate).
%
% * `'dtrends='` [ *`true`* | `false` ] - See the option `'dtrends='`
% option in [`model/simulate`](model/simulate).
%
% * `'shockSize='` [ *`'std'`* | numeric ] - Size of the shock that will
% be simulated; `'std'` means that one std dev of the shock will be
% simulated.
%
% Options affecting the graphs
% =============================
%
% See help on [`dbase/dbplot`](dbase/dbplot) for other options available.
%
% Description
% ============
%
% The simulated shock always occurs at time `t=1`. sStarting the simulation
% range, `SimRange`, before `t=1` allows you to simulate anticipated
% shocks.
%
% The graphs automatically include one pre-sample period, i.e. one period
% prior to the start of the simulation.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    if ischar(PlotList)
        PlotList = {PlotList};
    end
catch %#ok<CTCH>
    PlotList = {};
end

pp = inputParser();
if ismatlab
pp.addRequired('M',@(x) isa(x,'model'));
pp.addRequired('SHOCKNAME',@ischar);
pp.addRequired('RANGE',@isnumeric);
pp.addRequired('LIST',@(x) ischar(x) || iscellstr(PlotList));
pp.parse(This,ShockName,SimRange,PlotList);
else
pp = pp.addRequired('M',@(x) isa(x,'model'));
pp = pp.addRequired('SHOCKNAME',@ischar);
pp = pp.addRequired('RANGE',@isnumeric);
pp = pp.addRequired('LIST',@(x) ischar(x) || iscellstr(PlotList));
pp = pp.parse(This,ShockName,SimRange,PlotList);
end

[opt,varargin] = passvalopt('model.shockplot',varargin{:});

%--------------------------------------------------------------------------

elist = This.name(This.nametype == 3);
eindex = strcmp(elist,ShockName);
if ~any(eindex)
    utils.error('model', ...
        'This is not a valid name of a shock: ''%s''.', ...
        ShockName);
end

if strcmpi(opt.shocksize,'std')    
    opt.shocksize = permute(This.stdcorr(1,eindex,:),[1,3,2]);
end

if opt.deviation
    d = zerodb(This,SimRange);
else
    d = sstatedb(This,SimRange);
end

d.(ShockName)(1,:) = opt.shocksize;
S = simulate(This,d,SimRange, ...
    'deviation=',opt.deviation,'dtrends=',opt.dtrends,'dboverlay=',true, ...
    opt.simulate{:});

if ~isempty(PlotList)
    [FF,AA] = dbplot(S,SimRange(1)-1:SimRange(end),PlotList, ...
        varargin{:},opt.dbplot{:});
end

end