function Pos = position(This,K)
% position  [Not a public function] Position of a charcode in the storage.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

dblK = double(K);
if ~ismatlab
    dblK = back2highCharCode(dblK);
end

Pos = round(dblK - This.offset);

if Pos < 1 || Pos > length(This.storage)
    utils.error('fragileobj', ...
        'Charcode not found in the fragileobj object.');
end

end
