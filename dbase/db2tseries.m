function [X,List,Range] = db2tseries(D,varargin)
% db2tseries  Combine tseries database entries in one multivariate tseries object.
%
% Syntax
% =======
%
%     [X,Incl,Range] = db2tseries(D,List,Range)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database with tseries objects that will be
% combined in one multivariate tseries object.
%
% * `List` [ char | cellstr ] - List of tseries names that will be
% combined.
%
% * `Range` [ numeric | Inf ] - Date range.
%
% Output arguments
% =================
%
% * `X` [ numeric ] - Combined multivariate tseries object.
%
% * `Incl` [ cellstr ] - List of tseries names that have been actually
% found in the database.
%
% * `Range` [ numeric ] - The date range actually used.
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

[X,List,Range] = db2array(D,varargin{:});
X = tseries(Range,X);

end