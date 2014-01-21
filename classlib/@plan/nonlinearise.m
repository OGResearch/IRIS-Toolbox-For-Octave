function This = nonlinearise(This,varargin)
% nonlinearise  Select equations for simulation in an exact non-linear mode.
%
% Syntax
% =======
%
%     P = nonlinearise(P)
%     P = nonlinearise(P,Range)
%     P = nonlinearise(P,List,Range)
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan object.
%
% * `List` [ cellstr ] - List of labels for equations that will be simulated in
% an exact non-linear mode; all selected equations must be marked by an
% [`=#`](modellang/exactnonlin) mark in the model file. If `List` is not
% specified, all equations marked in the model file will be simulated in a
% non-linear mode.
%
% * `Range` [ numeric ] - Date range on which the equations will be
% simulated in an exact non-linear mode; currently, the range must start at
% the start of the plan range. If `Range` is not specified, the equations
% are non-linearised over the whole simulation range.
%
% Output arguments
% =================
%
% * `P` [ plan ] - Simulation plan with information on exact non-linear
% simulation included.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if isempty(varargin)
    list = Inf;
    dat = This.startDate : This.endDate;
else
    % List of equations or Inf for all.
    if isequal(varargin{1},Inf) || ischar(varargin{1}) || iscellstr(varargin{1})
        list = varargin{1};
        varargin(1) = [];
    else
        list = Inf;
    end
    % Dates.
    dat = varargin{1};
end

% Parse input arguments.
pp = inputParser();
pp = pp.addRequired('P',@(x) isa(x,'plan'));
pp = pp.addRequired('LIST',@(x) isequal(x,Inf) || ischar(x) || iscellstr(x));
pp = pp.addRequired('DAT', ...
    @(x) isnumeric(x) && all(datfreq(x) == datfreq(This.startDate)));
pp = pp.parse(This,list,dat);

%--------------------------------------------------------------------------

nper = round(This.endDate - This.startDate + 1);
datindex = round(dat - This.startDate + 1);
if any(datindex < 1 | datindex > nper)
    utils.error('plan', ...
        'Some of the non-linearised dates are out of plan range.');
end

if isequal(list,Inf)
    This.qAnchors(:,datindex) = true;
    return
end

if ischar(list)
    list = {list};
end

nlist = length(list);
found = true(1,nlist);
for i = 1 : nlist
    usrlabel = list{i};
    nusrlabel = length(usrlabel);
    if nusrlabel > 3 && strcmp(usrlabel(end-2:end),'...')
        eqtnindex = strncmp(This.qList,usrlabel,nusrlabel-3);
    else
        eqtnindex = strcmp(This.qList,usrlabel);
    end
    if any(eqtnindex)
        This.qAnchors(eqtnindex,datindex) = true;
    else
        found(i) = false;
    end
end

if any(~found)
    utils.error('plan', ...
        'Cannot non-linearise this equation: ''%s''.', ...
        list{~found});
end

end