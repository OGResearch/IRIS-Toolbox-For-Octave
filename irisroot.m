function X = irisroot()
% irisroot  Current IRIS root folder.
%
% Syntax
% =======
%
%     irisroot
%     X = irisroot()
%
% Output arguments
% =================
%
% * `X` [ char ] - Path to the IRIS root folder.
%
% Description
% ============
%
% The `irisroot` function is equivalent to the following call to
% [`irisget`](config/irisget)
%
%     irisget('irisroot')
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

X = irisconfigmaster('get','irisroot');

end