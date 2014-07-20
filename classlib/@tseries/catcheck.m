function [Outp,IxTseries] = catcheck(varargin)
% catcheck  [Not a public function] Check input arguments for tseries object concatenation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Non-tseries inputs.
try
   IxTseries = cellfun(@istseries,varargin);
   ixNumeric = cellfun(@isnumeric,varargin);
catch
   IxTseries = cellfun('isclass',varargin,'tseries');
   ixNumeric = cellfun('isclass',varargin,'double') ...
      | cellfun('isclass',varargin,'single') ...
      | cellfun('isclass',varargin,'logical');
end
remove = ~IxTseries & ~ixNumeric;

% Remove non-tseries or non-numeric inputs and display warning.
if any(remove)
   utils.warning('tseries:catcheck', ...
      'Non-tseries and non-numeric inputs removed from concatenation.');
   varargin(remove) = [];
   IxTseries(remove) = [];
   ixNumeric(remove) = [];
end

% Check frequencies.
freq = zeros(size(varargin));
freq(~IxTseries) = Inf;
for i = find(IxTseries)
   freq(i) = datfreq(varargin{i}.start);
end
ixNan = isnan(freq);
%freq(isnan(freq)) = [];
if sum(~ixNan & IxTseries) > 1 ...
      && any(diff(freq(~ixNan & IxTseries)) ~= 0)
   utils.error('tseries:catcheck', ...
       'Cannot concatenate tseries objects with different frequencies.');
elseif all(ixNan | ~IxTseries)
   freq(:) = 0;
else
   freq(ixNan & IxTseries) = freq(find(~ixNan & IxTseries,1));
end
Outp = varargin;

end
