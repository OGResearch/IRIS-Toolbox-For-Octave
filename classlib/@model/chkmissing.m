function [Ok,Miss] = chkmissing(M,D,Start,varargin)
% chkmissing  Check for missing initial values in simulation database.
%
% Syntax
% =======
%
%     [Ok,Miss] = chkmissing(M,D,Start)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `D` [ struct ] - Input database for the simulation.
%
% * `Start` [ numeric ] - Start date for the simulation.
%
% Output arguments
% =================
%
% * `Ok` [ `true` | `false` ] - True if the input database `D` contains
% all required initial values for simulating model `M` from date `Start`.
%
% * `Miss` [ cellstr ] - List of missing initial values.
%
% Options
% ========
%
% * `'error='` [ *`true`* | `false` ] - Throw an error if one or more
% initial values are missing.
%
% Description
% ============
%
% This function does not perform any simulation; it only checks for missing
% initial values in an input database.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

opt = passvalopt('model.chkmissing',varargin{:});

%--------------------------------------------------------------------------

Miss = {};
list = get(M,'required');
for i = 1 : length(list)
    try
        x = eval(['D.',list{i}]);
        x = x(Start);
    catch
        x = NaN;
    end
    if ~isnumeric(x) || any(isnan(x))
        Miss{end+1} = list{i}; %#ok<AGROW>
    end
end

Ok = isempty(Miss);
if ~Ok && opt.error
    utils.error('model:chkmissing', ...
        'This initial value is missing from input database: ''%s''', ...
        Miss{:});
end

end