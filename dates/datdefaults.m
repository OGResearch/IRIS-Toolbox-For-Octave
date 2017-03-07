function Opt = datdefaults(Opt,IsPlot)
% datdefaults  [Not a public function] Set up defaults for date-related opt if they are `@config`.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

persistent CONFIG;

try
    IsPlot; %#ok<VUNUS>
catch
    IsPlot = false;
end

%--------------------------------------------------------------------------

if isempty(CONFIG)
    CONFIG = irisconfigmaster('get');
end

if ~isfield(Opt,'dateformat') || isequal(Opt.dateformat,@config)
    if ~IsPlot
        Opt.dateformat = CONFIG.dateformat;
    else
        Opt.dateformat = CONFIG.plotdateformat;
    end
end

if ~isfield(Opt,'freqletters') || isequal(Opt.freqletters,@config)
    Opt.freqletters = CONFIG.freqletters;
end

if ~isfield(Opt,'months') || isequal(Opt.months,@config)
    Opt.months = CONFIG.months;
end

if ~isfield(Opt,'standinmonth') || isequal(Opt.standinmonth,@config)
    Opt.standinmonth = CONFIG.standinmonth;
end

end
