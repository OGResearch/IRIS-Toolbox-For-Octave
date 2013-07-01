function x = hpdi(x,prob,dim)
% hpdi  Highest probability density interval.
%
% Syntax
% =======
%
%     int = hpdi(x,prob)
%
% Input arguments
% ================
%
% * `x` [ tseries ] - Input data with random draws in each period.
%
% * `prob` [ numeric ] - Percent coverage of the computed interval, between
% 0 and 100.
%
% Output arguments
% =================
%
% * `int` [ tseries ] - Output tseries object with two columns, i.e. lower
% bounds and upper bounds for each period.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if ~exist('dim','var')
    dim = 1;
end

if dim > 2
    dim = 2;
end

%**************************************************************************

[low,high] = tseries.myhpdi(x.data(:,:),prob,dim);

if dim == 1
    x = [low;high];
else
    x.data = [low,high];
    x.Comment = {'HPDI low','HPDI high'};
    x = mytrim(x);
end

end