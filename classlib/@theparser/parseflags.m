function [S,InvalidFlag] = parseflags(This,Blk,S) %#ok<INUSL>
% parseflags  [Not a public function] Find flagged names.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(strfind(Blk,'!all_but'))
    default = false;
else
    default = true;
    Blk = strrep(Blk,'!all_but','');
end

for i = 1 : length(S)
    S(i).nameflag(:) = default;
end

allnames = [S(:).name];
allFlags = default(ones(size(allnames)));

% Replace regular expressions \<...\> with the list of matched names.
ptn = '\\?<(.*?)\\?>';
if is.matlab % ##### MOSW
    replaceFunc = @doExpand; %#ok<NASGU>
    Blk = regexprep(Blk,ptn,'${replaceFunc($1)}');
else
    Blk = mosw.octfun.dregexprep(Blk,ptn,'doExpand',1); %#ok<UNRCH>
end


    function c = doExpand(c0)
        start = regexp(allnames,['^',c0,'$']);
        index = ~cellfun(@isempty,start);
        c = sprintf('%s ',allnames{index});
    end % doExpand()


flagged = regexp(Blk,'\<[a-zA-Z]\w*\>','match');
nFlagged = length(flagged);
invalid = false(size(flagged));
for iFlagged = 1 : nFlagged
    name = flagged{iFlagged};
    index = strcmp(name,allnames);
    if any(index)
        allFlags(index) = ~default;
    else
        invalid(iFlagged) = true;
    end 
end

InvalidFlag = flagged(invalid);
if any(invalid)
    InvalidFlag = unique(InvalidFlag);
end

for is = 1 : length(S)
    nname = length(S(is).name);
    S(is).nameflag(:) = allFlags(1:nname);
    allFlags(1:nname) = [];
end

end
