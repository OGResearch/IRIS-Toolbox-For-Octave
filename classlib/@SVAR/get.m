function varargout = get(varargin)
% get  Query SVAR object properties.
%
% Syntax
% =======
%
%     value = get(v,query)
%     [value,value,...] = get(v,query,query,...)
%
% Input arguments
% ================
%
% * `v` [ SVAR ] - SVAR object.
%
% * `query` [ char ] - Name of the queried property.
%
% Output arguments
% =================
%
% * `value` [ ... ] - Value of the queried property.
%
% All properties accessible through the `get` function in VAR objects are
% also accessible in SVAR objects.
%
% Valid queries on SVAR objects
% ==============================
%
% Description
% ============
%
% Example
% ========

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

% We need to create `SVAR.get` to provide help. `VAR.get` calls VAR- or
% SVAR-specific `specget` methods.
[varargout{1:nargout}] = get@VAR(varargin{:});

end