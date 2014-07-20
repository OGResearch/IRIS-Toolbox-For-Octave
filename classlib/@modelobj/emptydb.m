function D = emptydb(This)
% emptydb  Create model-specific database with empty tseries for all variables and shocks.
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
% variable and each shock, and a vector of currently assigned values for
% each parameter.
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

nAlt = size(This.Assign,3);
x = cell(size(This.name));
x(This.nametype <= 3) = {tseries(NaN,zeros(0,nAlt))};
D = cell2struct(x,This.name,2);
D = addparam(This,D);

end