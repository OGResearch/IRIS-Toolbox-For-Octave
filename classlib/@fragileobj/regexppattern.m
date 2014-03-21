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

n = length(This.storage);
cCode = This.offset + 1;
if ~ismatlab
    cCode = highCharCode2utf8(cCode);
end
first = char(cCode);
cCode = This.offset + n;
if ~ismatlab
    cCode = highCharCode2utf8(cCode);
end
last = char(cCode);
P = [first,'-',last];

end