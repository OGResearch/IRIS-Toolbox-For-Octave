function P = regexppattern(This)
% regexppattern  [Not a public function] Regexp list of all replacement codes.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

n = length(This.storage);
first = char(This.offset + 1);
last = char(This.offset + n);
P = [first,'-',last];

end