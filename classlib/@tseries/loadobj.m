function This = loadobj(This)
% loadobj  [Not a public function] Prepare tseries object for loading from disk.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isstruct(This)
   This = tseries(This);
end

This = mystamp(This);

end
