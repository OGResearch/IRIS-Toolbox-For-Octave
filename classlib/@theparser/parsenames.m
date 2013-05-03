function [Name,Label,Value,NameFlag] = parsenames(Blk)
% parsenames [Not a public function] Parse names within a name block.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Protect first-level round and square brackets; this is to handle
% assignments with function calls and possibly multiple input arguments to
% those functions separated with commas.
offset = irisget('highcharcode');
[Blk,storage] = xxProtectBrackets(Blk,offset);

% Parse names with labels and assignments.
patt = ['(?<label>#\(\d+\))?\s*', ... % Label.
    '(?<name>[a-zA-Z]\w*)\s*', ... % Name.
    '(?<value>=[^;,\n]+[;,\n])?']; % Value.

x = regexp(Blk,patt,'names');
Name = {x(:).name};
Label = {x(:).label};
Value = {};
if nargout > 2
    Value = {x(:).value};
    Value = strrep(Value,'=','');
    Value = strrep(Value,'!','');
    Value = xxBracketsBack(Value,storage,offset);
end
NameFlag = false(size(Name));

end

% Subfunctions.

%**************************************************************************
function [Blk,Storage] = xxProtectBrackets(Blk,Offset)
% xxProtectBrackets  Replace first-level (...) and [...] with char(X),
% avoid #() that are used to protect labels.

Storage = {};
allOpen = find(Blk == '(' | Blk == '[');
for open = allOpen
    if open == 1 || Blk(open-1) == '#'
        continue
    end
    close = strfun.matchbrk(Blk,open);
    Storage{end+1} = Blk(open:close); %#ok<AGROW>
    pos = length(Storage);
    Blk = [Blk(1:open-1),char(Offset+pos),Blk(close+1:end)];
end

end % doProtectBrackets().

%**************************************************************************
function C = xxBracketsBack(C,Storage,Offset)

nStorage = length(Storage);
pattern = ['[',char(Offset+(1:nStorage)),']'];
C = regexprep(C,pattern,'${Storage{double($0)-Offset}}');

end