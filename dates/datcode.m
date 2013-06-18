function dat = datcode(freq,year,varargin)
% datcode  [Not a public function] IRIS serial date number.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if isempty(varargin)
   per = ones(size(year));
else
   per = varargin{1};
end

%**************************************************************************

dat = year.*freq + per - 1 + freq/100;

if any(freq(:) == 0)
   if length(freq) == 1
      dat(:) = per(:);
   else
      index = freq == 0;
      dat(index) = per(index);
   end
end

end
