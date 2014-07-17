function Pos = blkpos(This,Blk)
% blkpos  [Not a public function] Positions of blocks in an initialized theparser obj.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ischar(Blk)
    Blk = {Blk};
end

nBlk = numel(Blk);
Pos = nan(size(Blk));
for iBlk = 1 : nBlk
    inx = strcmp(This.BlkName,Blk{iBlk});
    if any(inx)
        Pos(iBlk) = find(inx,1);
    end
end

if any(isnan(Pos))
    utils.error('theparser:blkpos', ...
        'Block not found in the parser object: ''%s''.', ...
        Blk{isnan(Pos)});
end

end
