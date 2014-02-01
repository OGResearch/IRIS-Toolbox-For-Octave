function D = emptydb(This)
% emptydb  Create model-specific database with variables, shocks, and parameters.
%
% Syntax
% =======
%
%     D = emptydb(M)
%
% Input arguments
% ================
%
% * `M` [ model | bkwmodel ] - Model or bkwmodel object for which the empty
% database will be created.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Database with an empty tseries object for each
% variable and each shock, and an empty array for each parameter.
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

x = cell(size(This.name));
x(This.nametype <= 3) = {tseries()};
x(This.nametype == 4) = {[]}; 
D = cell2struct(x,This.name,2);

end