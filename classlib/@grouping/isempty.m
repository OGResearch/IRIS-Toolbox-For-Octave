function Flag = isempty(This)
% isempty  True for empty grouping object.
%
% Syntax
% =======
%
%     Flag = isempty(G)
%
% Input arguments
% ================
%
% * `G` [ grouping ] - Grouping object.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if `G` is an empty grouping object.
%
% Description
% ============
%
% Example
% ========
%
%     g = grouping();
%     isempty(g)
%     ans = 
%          1
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = isempty(This.groupNames);

end