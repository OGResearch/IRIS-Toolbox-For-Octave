function [Opt,Config] = datdefaults(Opt,IsPlot)
% datdefaults  [Not a public function] Set up defaults for date-related opt if they are 'config'.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    IsPlot; %#ok<VUNUS>
catch
    IsPlot = false;
end

%--------------------------------------------------------------------------

Config = irisget();

if ~isfield(Opt,'dateformat') || isequal(Opt.dateformat,'config')
    if ~IsPlot
        Opt.dateformat = Config.dateformat;
    else
        Opt.dateformat = Config.plotdateformat;
    end
end

if ~isfield(Opt,'freqletters') || isequal(Opt.freqletters,'config')
    Opt.freqletters = Config.freqletters;
end

if ~isfield(Opt,'months') || isequal(Opt.months,'config')
    Opt.months = Config.months;
end

if ~isfield(Opt,'standinmonth') || isequal(Opt.standinmonth,'config')
    Opt.standinmonth = Config.standinmonth;
end

end
