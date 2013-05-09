function [S,Range,Select] = icrf(This,Time,varargin)
% icrf  Initial-condition response functions.
%
% Syntax
% =======
%
%     S = icrf(M,NPer,...)
%     S = icrf(M,Range,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object for which the initial condition responses
% will be simulated.
%
% * `Range` [ numeric ] - Date range with the first date being the shock
% date.
%
% * `NPer` [ numeric ] - Number of periods.
%
% Output arguments
% =================
%
% * `S` [ struct ] - Database with initial condition response series.
%
% Options
% ========
%
% * `'delog='` [ *`true`* | `false` ] - Delogarithmise the responses for
% variables declared as `!variables:log`.
%
% * `'size='` [ numeric | *`1`* for linear models | *`log(1.01)`* for non-linear
% models ] - Size of the deviation in initial conditions.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Parse options.
opt = passvalopt('model.icrf',varargin{:});

if ~isempty(opt.log)
    opt.delog = opt.log;
end

% TODO: Introduce `'select='` option.

%--------------------------------------------------------------------------

nb = size(This.solution{1},2);

% Set the size of the initial conditions.
if isempty(opt.size)
    % Default.
    if This.linear
        icSize = ones(1,nb);
    else
        icSize = ones(1,nb)*log(1.01);
    end
else
    % User supplied.
    icSize = ones(1,nb)*opt.size;
end

Select = get(This,'initcond');
Select = regexprep(Select,'log\((.*?)\)','$1','once');

func = @(T,R,K,Z,H,D,U,Omg,ialt,nper) ...
    timedom.icrf(T,[],[],Z,[],[],U,[], ...
    nper,icSize,This.icondix);

[S,Range] = myrf(This,Time,func,Select,opt);

end