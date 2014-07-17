function [TTrend,BaseYear] = dat2ttrend(Range,BaseYear)
% dat2ttrend  Construct linear time trend from date range.
%
% Syntax
% =======
%
%     [TTrend,BaseDate] = dat2ttrend(Range)
%     [TTrend,BaseDate] = dat2ttrend(Range,BaseYear)
%     [TTrend,BaseDate] = dat2ttrend(Range,Obj)
%
% Input arguments
% ================
%
% * `Range` [ numeric ] - Date range from which an integer linear time
% trend will be constructed.
%
% * `BaseYear` [ model | VAR ] - Base year that will be used to construct
% the time trend.
%
% * `Obj` [ model | VAR ] - Model or VAR object whose base year will be
% used to construct the time trend; if both `BaseYear` and `Obj` are
% omitted, the base year from `irisget('baseYear')` will be used.
%
% Output arguments
% =================
%
% * `TTrend` [ numeric ] - Integer linear time trend, unique to the input
% date range `Range` and the base year.
%
% * `BaseDate` [ numeric ] - Base date used to normalize the input date
% range; see Description.
%
% Description
% ============
%
% For regular date frequencies, the time trend is constructed the following
% way. First, a base date is created first period in the base year of a
% given frequency. For instance, for a quarterly input range, `BaseDate =
% qq(baseYear,1)`, for a monthly input range, `BaseDate == mm(baseYear,1)`,
% etc. Then, the output trend is an integer vector normalized to the base
% date,
%
%     TTrend = floor(Range - BaseDate);
%
% For indeterminate date frequencies, `BaseDate = 0`, and the output
% time trend is simply the input date range.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    if ~isintscalar(BaseYear)
        BaseYear = get(BaseYear,'baseYear');
    end
catch
    BaseYear = @config;
end

%--------------------------------------------------------------------------

if ~isintscalar(BaseYear)
    BaseYear = irisget('baseYear');
end

if isempty(Range)
    TTrend = Range;
else
    freq = datfreq(Range(1));
    if freq == 0
        TTrend = Range;
        BaseYear = 0;
    else
        baseDate = datcode(freq,BaseYear,1);
        TTrend = floor(Range - baseDate);
    end
end

end
