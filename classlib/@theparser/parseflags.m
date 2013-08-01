function [S,INVALIDFLAG] = parseflags(BLK,S)

if isempty(strfind(BLK,'!allbut'))
    default = false;
else
    default = true;
    BLK = strrep(BLK,'!allbut','');
end

for i = 1 : length(S)
    S(i).nameflag(:) = default;
end

allnames = [S(:).name];
allflags = default(ones(size(allnames)));

% Replace regular expressions \<...\> or {...} with the list of matched
% names.
replacefunc = @doexpand; %#ok<NASGU>
BLK = regexprep(BLK,'\\?<(.*?)\\?>','${replacefunc($1)}');

    function c = doexpand(c0)
        start = regexp(allnames,['^',c0,'$']);
        index = ~cellfun(@isempty,start);
        c = sprintf('%s ',allnames{index});
    end

flagged = regexp(BLK,'\<[a-zA-Z]\w*\>','match');
nflagged = length(flagged);
invalid = false(size(flagged));
for iflagged = 1 : nflagged
    name = flagged{iflagged};
    index = strcmp(name,allnames);
    if any(index)
        allflags(index) = ~default;
    else
        invalid(iflagged) = true;
    end 
end

INVALIDFLAG = flagged(invalid);
if any(invalid)
    INVALIDFLAG = unique(INVALIDFLAG);
end

for is = 1 : length(S)
    nname = length(S(is).name);
    S(is).nameflag(:) = allflags(1:nname);
    allflags(1:nname) = [];
end

end
