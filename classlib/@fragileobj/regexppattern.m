function P = regexppattern(This)
% regexppattern  [Not a public function] Regexp list of all replacement codes.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(This)
    P = '';
    return
end

n = length(This.Storage);
first = char(This.Offset + 1);
last = char(This.Offset + n);
P = [first,'-',last];

end