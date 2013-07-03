function DATES = find(X,FLAG)
% find  Find dates at which tseries observations are non-zero or true.
%
% Syntax
% =======
%
%     DATES = find(X)
%     DATES = find(X,FLAG)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object.
%
% * `FLAG` [ @all | @any ] - Controls whether the output `DATES` will
% contain periods where all observations are non-zero, or where at least
% one observation is non-zero. If not specified, |@all| is
% assumed.
%
% Output arguments
% =================
%
% * `DATES` [ numeric | cell ] - Vector of dates at which all or any
% (depending on `FLAG`) of the observations are non-zero.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if ~exist('FLAG','var')
    FLAG = @all;
end

if ~isequal(FLAG,@all) && ~isequal(FLAG,@any)
    error('iris:tseries','FLAG must be either @all or @any.');
end

%**************************************************************************

index = FLAG(X.data(:,:),2);
DATES = X.start + find(index) - 1;

end