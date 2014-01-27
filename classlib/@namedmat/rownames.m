function x = rownames(this)
% rownames  Names of rows in namedmat object.
%
% Syntax
% =======
%
%     NAMES = rownames(X)
%
% Input arguments
% ================
%
% * `X` [ namedmat ] - A namedmat object (an numeric array with named rows
% and columns) returned by some of the model functions.
%
% Output arguments
% =================
%
% * `NAMES` [ cellstr ] - Names of rows in `X`.
%
% Description
% ============
%
% Example
% ========
%

%
% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

x = this.Rownames;

end
