function This = autoexogenise(This,List,Dates,Weight)
% autoexogenise  Exogenise variables and automatically endogenise corresponding shocks.
%
% Syntax
% =======
%
%     P = autoexogenise(P,List,Dates)
%     P = autoexogenise(P,List,Dates,Flag)
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
% * `List` [ cellstr | char ] - List of variables that will be exogenised;
% these variables must have their corresponding shocks assigned, see
% [`!autoexogenise`](modellang/autoexogenise).
%
% * `Dates` [ numeric ] - Dates at which the variables will be exogenised.
%
% * `Flag` [ 1 | 1i ] - Select the shock anticipation mode; if not
% specified, `Flag = 1`.
%
% Output arguments
% =================
%
% * `P` [ plan ] - Simulation plan with new information on exogenised
% variables and endogenised shocks included.
%
% Description
% ============
%
% Example
% ========

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

try
    Weight;
catch
    Weight = 1;
end

if isnumeric(List) && (ischar(Dates) || iscellstr(Dates))
    [List,Dates] = deal(Dates,List);
end

% Parse required input arguments.
pp = inputParser();
if ismatlab
pp.addRequired('P',@is.plan);
pp.addRequired('List',@(x) ischar(x) || iscellstr(x));
pp.addRequired('Dates',@isnumeric);
pp.addRequired('Weight', ...
    @(x) is.numericscalar(x) && ~(real(x) ~=0 && imag(x) ~=0) ...
    && real(x) >= 0 && imag(x) >= 0 && x ~= 0);
pp.parse(This,List,Dates,Weight);
else
pp = pp.addRequired('P',@(varargin)is.plan(varargin{:}));
pp = pp.addRequired('List',@(x) ischar(x) || iscellstr(x));
pp = pp.addRequired('Dates',@isnumeric);
pp = pp.addRequired('Weight', ...
    @(x) is.numericscalar(x) && ~(real(x) ~=0 && imag(x) ~=0) ...
    && real(x) >= 0 && imag(x) >= 0 && x ~= 0);
pp = pp.parse(This,List,Dates,Weight);
end

% Convert char list to cell of str.
if ischar(List)
    List = regexp(List,'[A-Za-z]\w*','match');
end

if isempty(List)
    return
end

%--------------------------------------------------------------------------

nList = numel(List);
valid = true(1,nList);

for i = 1 : nList
    xInx = strcmp(This.XList,List{i});
    nPos = This.AutoEx(xInx);
    if ~any(xInx) || isnan(nPos)
        valid(i) = false;
        continue
    end
    This = exogenise(This,This.XList{xInx},Dates);    
    This = endogenise(This,This.NList{nPos},Dates,Weight);
end

if any(~valid)
    utils.error('plan', ...
        'Cannot autoexogenise this name: ''%s''.', ...
        List{~valid});
end

end