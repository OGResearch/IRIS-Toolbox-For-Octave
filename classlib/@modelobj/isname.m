function varargout = isname(M,varargin)
% isname  True for valid names of variables, parameters, or shocks in model object.
%
% Syntax
% =======
%
%     Flag = isname(M,Name)
%     [Flag,Flag,...] = isname(M,Name,Name,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `Name` [ char ] - A text string that will be matched against the names
% of variables, parameters and shocks in the model object `M`.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True for input strings that are valid
% names in the model object `M`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

varargout = cell(1,length(varargin));
for i = 1 : length(varargin)
    varargout{i} = any(strcmp(M.name,varargin{i}));
end

end