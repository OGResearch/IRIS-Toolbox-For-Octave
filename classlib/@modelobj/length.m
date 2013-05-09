function N = length(This)
% length  Number of alternative parameterisations.
%
% Syntax
% =======
%
%     N = length(M)
%
% Input arguments
% ================
%
% * `M` [ model | esteq ] - Model or esteq object.
%
% Output arguments
% =================
%
% * `N` [ numeric ] - Number of alternative parameterisations.
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

N = size(This.Assign,3);

end