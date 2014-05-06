function [S,InvalidFlag] = parseflags(This,Blk,S) %#ok<INUSL>

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

% Replace regular expressions \<...\> or {...} with the list of matched
% names.
if ismatlab
    replacefunc = @doexpand; %#ok<NASGU>
    Blk = regexprep(Blk,'\\?<(.*?)\\?>','${replacefunc($1)}');
else
    Blk = myregexprep(Blk,'\\?<(.*?)\\?>','${doexpand($1)}');
end

    function c = doexpand(c0)
        start = regexp(allnames,['^',c0,'$']);
        index = ~cellfun(@isempty,start);
        c = sprintf('%s ',allnames{index});
    end

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
