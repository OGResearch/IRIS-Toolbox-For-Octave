function Blk = human(Human,XBlk)
% human  [Not a public function] Convert variable and equation blocks to human readable blocks.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Blk = cell(1,0);
if ~isempty(XBlk)
    nBlk = length(XBlk);
    Blk = cell(1,nBlk);
    for i = 1 : nBlk
        Blk{i} = Human(XBlk{i});
    end
end

end