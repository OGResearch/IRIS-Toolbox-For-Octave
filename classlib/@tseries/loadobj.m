function this = loadobj(this)
% LOADOBJ  [Not a public function] Prepare tseries object for loading from disk.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

if isstruct(this)
   this = tseries(this);
end

end