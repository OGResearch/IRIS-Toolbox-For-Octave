function [X,list,range] = db2tseries(d,varargin)
% db2tseries  Combine tseries database entries in one multivariate tseries object.
%
% Syntax
% =======
%
%     [X,INCL,RANGE] = db2tseries(D,LIST,RANGE)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database with tseries objects that will be
% combined in one multivariate tseries object.
%
% * `LIST` [ char | cellstr ] - List of tseries names that will be
% combined.
%
% * `RANGE` [ numeric | Inf ] - Date range.
%
% Output arguments
% =================
%
% * `X` [ numeric ] - Combined multivariate tseries object.
%
% * `INCL` [ cellstr ] - List of tseries names that have been actually
% found in the database.
%
% * `RANGE` [ numeric ] - The date range actually used.
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

[X,list,range] = db2array(d,varargin{:});
X = tseries(range,X);

end