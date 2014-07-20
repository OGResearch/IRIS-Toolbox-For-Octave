function [Blk,InvalidKey,InvalidAllBut] = readblk(This)
% readblk  [Not a public function] Read individual blocks of theparser code.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

nBlk = length(This.BlkName);

% Check all words starting with an !.
InvalidKey = xxChkKey(This);
InvalidAllBut = false;

% Add new line character at the end of the file.
if isempty(This.Code) || This.Code(end) ~= char(10)
    This.Code(end+1) = char(10);
end

% End of block (eob) is start of another block or end of file.
inx = ~cellfun(@isempty,This.BlkName);
eob = sprintf('|%s',This.BlkName{inx});
eob = ['(?=$',eob,')'];

% Remove redundant semicolons.
This.Code = regexprep(This.Code,'(\s*;){2,}',';');

% Read blocks.
Blk = cell(1,nBlk);
for iBlk = 1 : nBlk
    if isempty(This.BlkName{iBlk})
        continue
    end
    % Read a whole block.
    pattern = [This.BlkName{iBlk},'[;\s]+(.*?)',eob];
    tokens = regexpi(This.Code,pattern,'tokens');
    tokens = [tokens{:}];
    if ~isempty(tokens)
        % !all_but must be in all or none of log declaration blocks.
        if This.IxLogBlk(iBlk)
            InvalidAllBut = InvalidAllBut || xxChkAllBut(tokens);
        end
        Blk{iBlk} = [tokens{:}];
    else
        Blk{iBlk} = '';
    end
end

end


% Subfunctions...


%**************************************************************************


function InvalidKey = xxChkKey(This)
inx = ~cellfun(@isempty,This.BlkName);
allowed = [This.BlkName(inx),This.OtherKey,{'!all_but'}];

key = regexp(This.Code,'!\w+','match');
nKey = length(key);
valid = true(1,nKey);
for iKey = 1 : nKey
    valid(iKey) = any(strcmp(key{iKey},allowed));
end
InvalidKey = key(~valid);
end % xxChkKey()


%**************************************************************************


function Invalid = xxChkAllBut(Tokens)
% The keyword `!all_but` must be in all or none of flag blocks.
inx = cellfun(@isempty,regexp(Tokens,'!all_but','match','once'));
Invalid = any(inx) && ~all(inx);
end % xxChkAllBut()
