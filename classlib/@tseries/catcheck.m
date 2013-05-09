function [outputs,ixtseries] = catcheck(varargin)
% catcheck  [Not a public function] Check input arguments for tseries object concatenation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

% Non-tseries inputs.
try
   ixtseries = cellfun(@istseries,varargin);
   ixnumeric = cellfun(@isnumeric,varargin);
catch
   ixtseries = cellfun('isclass',varargin,'tseries');
   ixnumeric = cellfun('isclass',varargin,'double') ...
      | cellfun('isclass',varargin,'single') ...
      | cellfun('isclass',varargin,'logical');
end
remove = ~ixtseries & ~ixnumeric;

% Remove non-tseries or non-numeric inputs and display warning.
if any(remove)
   warning('iris:tseries', ...
      'Non-tseries and non-numeric inputs removed from concatenation.');
   varargin(remove) = [];
   ixtseries(remove) = [];
   ixnumeric(remove) = [];
end

% Check frequencies.
freq = zeros(size(varargin));
freq(~ixtseries) = Inf;
for i = find(ixtseries)
   freq(i) = datfreq(varargin{i}.start);
end
ixnan = isnan(freq);
%freq(isnan(freq)) = [];
if sum(~ixnan & ixtseries) > 1 ...
      && any(diff(freq(~ixnan & ixtseries)) ~= 0)
   error('Cannot concatenate tseries objects with different frequencies.');
elseif all(ixnan | ~ixtseries)
   freq(:) = 0;
else
   freq(ixnan & ixtseries) = freq(find(~ixnan & ixtseries,1));
end
outputs = varargin;

end
