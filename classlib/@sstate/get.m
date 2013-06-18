function varargout = get(this,varargin)
% get  Query to sstate object.
%
% Syntax
% =======
%
%     Ans = get(S,Query)
%
% Input arguments
% ================
%
% * `S` [ sstate ] - Sstate object.
%
% * `Query` [ char ] - Query to the sstate object.
%
% Output arguments
% =================
%
% * `Ans` [ ... ] - Answer to the query.
%
% Valid queries to sstate objects
% ================================
%
% * `'nBlocks='` - Returns [ numeric ] the total number of equation blocks.
%
% * `'labels='` - Returns [ cellstr ] the list of block labels.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = get@getsetobj(this,varargin{:});

end