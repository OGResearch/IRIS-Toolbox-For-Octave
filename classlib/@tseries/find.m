function Dates = find(X,Flag)
% find  Find dates at which tseries observations are non-zero or true.
%
% Syntax
% =======
%
%     Dates = find(X)
%     Dates = find(X,Flag)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object.
%
% * `Flag` [ @all | @any ] - Controls whether the output `Dates` will
% contain periods where all observations are non-zero, or where at least
% one observation is non-zero. If not specified, |@all| is
% assumed.
%
% Output arguments
% =================
%
% * `Dates` [ numeric | cell ] - Vector of dates at which all or any
% (depending on `Flag`) of the observations are non-zero.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    Flag;
catch
    Flag = @all;
end

pp = inputParser();
pp.addRequired('X',@(x) isa(x,'tseries'));
pp.addRequired('Flag',@(x) isequal(x,@all) || isequal(x,@any));
pp.parse(X,Flag);

%--------------------------------------------------------------------------

ix = Flag(X.data(:,:),2);
Dates = X.start + find(ix) - 1;

end