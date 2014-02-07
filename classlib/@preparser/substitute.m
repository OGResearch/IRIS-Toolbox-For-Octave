function [C,S,Leftover,Multiple,Undef] = substitute(C)
% subsitutte  [Not a public function] Expand and replace substitutions in preparsed codes.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

S = struct();
Leftover = {}; %#ok<NASGU>
Multiple = {};
Undef = {};

%--------------------------------------------------------------------------

% Read substitution blocks.
[C,blk] = xxReadBlocks(C);

% Read names and bodies of individual substitutions. Do this in
% individual subs blocks separately to catch syntax errors such as the
% last subs definition not finished by a semicolon.
name = {};
body = {};
Leftover = {};
for i = 1 : length(blk)
    [name,body,temp] = xxReadSubs(blk{i},name,body);
    if ~isempty(temp)
        Leftover{end+1} = temp; %#ok<AGROW>
    end
end
if ~isempty(Leftover)
    return
end

% Check uniqueness of substitution names.
Multiple = strfun.nonunique(name);
if ~isempty(Multiple)
    return
end

% Expand substitutions.
[C,body] = xxExpand(C,name,body);

% Check for the occurence of undefined (unexpanded) or unresolved
% substitutions in the rest of the code. Unresolved substitutions can
% occur also because of wrong order of their definitions.
Undef = xxChkUndef(C);
if ~isempty(Undef)
    return
end

S = cell2struct(body,name,2);

end

% Subfunctions.

%**************************************************************************
function [C,Blk] = xxReadBlocks(C)

Blk = {};
% Read the blocks one by one to preserve their order in the
% model code. Remove the substitution blocks from the code.
while true
    [tok,start,finish] = ...
        regexp(C,'!substitutions(.*?)(?=![^!\s]|$)', ...
        'tokens','start','end','once');
    if isempty(start)
        break
    end
    Blk{end+1} = strtrim(tok{1}); %#ok<AGROW>
    C(start:finish) = '';
end

end % xxReadBlocks().

%**************************************************************************
function [Name,Body,Leftover] = xxReadSubs(B,Name,Body)

% Read substitution names and bodies. Again, do it one by one to
% preserve their order.
while true
    [tok,start,finish] = ...
        regexp(B,'(\<[a-zA-Z]\w*\>)\s*:?\s*=\s*([^;]*)\s*;', ...
        'tokens','start','end','once');
    if isempty(start)
        break
    end
    Name{end+1} = tok{1}; %#ok<AGROW>
    Body{end+1} = tok{2}; %#ok<AGROW>
    B(start:finish) = '';
end
Leftover = strtrim(B);

end % xxReadSubs().

%**************************************************************************
function [C,Body] = xxExpand(C,Name,Body)

% Expand substitutions in other substitutions first.
n = length(Name);
pattern = cell(1,n);
for i = 1 : n
    pattern{i} = ['$',Name{i},'$'];
    for j = i+1 : n
        Body{j} = strrep(Body{j},pattern{i},Body{i});
    end
end
% Expand substitutions in the rest of the code. Proceed backward so
% that unresolved substitutions in substitution bodies (pointing to
% substitutions defined later) remain unresolved and can be caught as
% an error.
for i = n : -1 : 1
    C  = strrep(C,pattern{i},Body{i});
end

end % xxExpand().

%**************************************************************************
function Undef = xxChkUndef(c)
% xxChkUndef  Check for undefined substitutions.

Undef = regexp(c,'\$\<[A-Za-z]\w*\>\$','match');
if ~isempty(Undef)
    Undef = unique(Undef);
end

end % xxChkUndef().