function [Ok,Miss] = chkmissing(This,D,Start,varargin)
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

% List of initial conditions.
nx = length(This.solutionid{2});
nb = size(This.solution{1},2);
nf = nx - nb;
id = This.solutionid{2}(nf+1:end);
ixInit = any(This.icondix,3);
id = id(ixInit);

for j = id
    realId = real(j);
    imagId = imag(j);
    name = This.name{realId};
    lag = imagId - 1;
    try
        x = D.(name){lag};
        x = x(Start);
    catch
        x = NaN;
    end
    if ~isnumeric(x) || any(isnan(x))
        Miss{end+1} = sprintf('%s{%g}',name,lag); %#ok<AGROW>
    end
end

Ok = isempty(Miss);
if ~Ok && opt.error
    utils.error('model:chkmissing', ...
        'This initial value is missing from input database: ''%s''.', ...
        Miss{:});
end

end