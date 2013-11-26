function varargout = get(This,varargin)
% get  Query VAR object properties.
%
% Syntax
% =======
%
%     Ans = get(V,Query)
%     [Ans,Ans,...] = get(V,Query,Query,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% * `Query` [ char ] - Query to the VAR object.
%
% Output arguments
% =================
%
% * `Ans` [ ... ] - Answer to the query.
%
% Valid queries to VAR objects
% =============================
%
% Description
% ============
%
% Example
% ========

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = get@getsetobj(This,varargin{:});

end
