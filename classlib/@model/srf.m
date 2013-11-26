function [S,Range,Select] = srf(This,Time,varargin)
% srf  Shock response functions.
%
% Syntax
% =======
%
%     S = srf(M,NPer,...)
%     S = srf(M,Range,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose shock responses will be simulated.
%
% * `Range` [ numeric ] - Simulation date range with the first date being
% the shock date.
%
% * `NPer` [ numeric ] - Number of simulation periods.
%
% Output arguments
% =================
%
% * `S` [ struct ] - Database with shock response time series.
%
% Options
% ========
%
% * `'delog='` [ *`true`* | `false` ] - Delogarithmise the responses for
% variables declared as `!variables:log`.
%
% * `'select='` [ cellstr | *`Inf`* ] - Run the shock response function for a
% selection of shocks only; `Inf` means all shocks are simulated.
%
% * `'size='` [ *'std'* | numeric ] - Size of the shocks that will be
% simulated; 'std' means that each shock will be set to its std dev
% currently assigned in the model object `m`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

opt = passvalopt('model.srf',varargin{:});

if ischar(opt.select)
    opt.select = regexp(opt.select,'\w+','match');
end

%--------------------------------------------------------------------------

ne = sum(This.nametype == 3);
nAlt = size(This.Assign,3);
eList = This.name(This.nametype == 3);

% Select shocks.
if isequal(opt.select,Inf)
    pos = 1 : ne;
else
    nSel = length(opt.select);
    pos = nan(1,nSel);
    for i = 1 : length(opt.select)
        x = find(strcmp(opt.select{i},eList));
        if length(x) == 1
            pos(i) = x;
        end
    end
    doChkShockSelection();
end
Select = eList(pos);
nSel = length(Select);

% Set the size of the shocks.
if ischar(opt.size)
    shkSize = This.stdcorr(1,pos,:);
else
    shkSize = opt.size*ones(1,nSel,nAlt);
end

func = @(T,R,K,Z,H,D,U,Omg,iAlt,nPer) ...
    timedom.srf(T,R(:,pos),[],Z,H(:,pos),[],U,[], ...
    nPer,shkSize(1,:,iAlt));

[S,Range,Select] = myrf(This,Time,func,Select,opt);

for i = 1 : length(Select)
    S.(Select{i}).data(1,i,:) = shkSize(1,i,:);
    S.(Select{i}) = mytrim(S.(Select{i}));
end

% Nested functions.

%**************************************************************************
    function doChkShockSelection()
        if any(isnan(pos))
            utils.error('model', ...
                'This is not a valid shock name: ''%s''.', ...
                opt.select{isnan(pos)});
        end
        nonUnique = strfun.nonunique(pos);
        if ~isempty(nonUnique)
            utils.error('model', ...
                'This shock name is requested more than once: ''%s''.', ...
                opt.select{nonUnique});
        end
    end % doChkShockSelection().

end