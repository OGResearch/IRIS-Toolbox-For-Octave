function [opt,config] = datdefaults(opt,isplot)
% datdefaults  [Not a public function] Set up defaults for date-related opt if they are 'config'.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

if nargin < 2
   isplot = false;
end

config = irisget();

if ~isfield(opt,'dateformat') || isequal(opt.dateformat,'config')
   if ~isplot
      opt.dateformat = config.dateformat;
   else
      opt.dateformat = config.plotdateformat;
   end
end

if ~isfield(opt,'freqletters') || isequal(opt.freqletters,'config')
   opt.freqletters = config.freqletters;
end

if ~isfield(opt,'months') || isequal(opt.months,'config')
   opt.months = config.months;
end

if ~isfield(opt,'standinmonth') || isequal(opt.standinmonth,'config')
   opt.standinmonth = config.standinmonth;
end

end
