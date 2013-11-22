function x = colnames(this)
% colnames  Names of columns in namedmat object.
%
% Syntax
% =======
%
%     NAMES = colnames(X)
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
% * `NAMES` [ cellstr ] - Names of columns in `X`.
%
% Description
% ============
%
% Example
% ========
%

%
% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

x = this.Colnames;

end