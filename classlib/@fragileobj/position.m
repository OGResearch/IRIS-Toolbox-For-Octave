function Pos = position(This,K)
% position  [Not a public function] Position of a charcode in the storage.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Pos = round(double(K) - This.Offset);

if Pos < 1 || Pos > length(This.Storage)
    utils.error('fragileobj', ...
        'Charcode not found in the fragileobj object.');
end

end