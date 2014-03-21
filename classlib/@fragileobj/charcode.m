function C = charcode(This)
% charcode  [Not a public function] Get the current replacement code.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

k = This.offset + length(This.storage);
if k > 65535
    utils.error('fragileobj', ...
        'Index of protected items exceeds 65535.');
end
if ~ismatlab
    k = highCharCode2utf8(k);
end
C = char(k);

end