function [Loggable,InvalidLog] = parselog(This,Blk,Loggable) %#ok<INUSL>
% parselog  [Not a public function] Find flagged names.
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

for i = 1 : length(Loggable)
    Loggable(i).IxLog(:) = default;
end

allNames = [Loggable(:).name];
allLog = default(ones(size(allNames)));

% Replace regular expressions \<...\> with the list of matched names.
ptn = '\\?<(.*?)\\?>';
if false % ##### MOSW
    replaceFunc = @doExpand; %#ok<NASGU>
    Blk = regexprep(Blk,ptn,'${replaceFunc($1)}');
else
    Blk = mosw.dregexprep(Blk,ptn,'doExpand',1); %#ok<UNRCH>
end


    function c = doExpand(c0)
        start = regexp(allNames,['^',c0,'$']);
        ix = ~cellfun(@isempty,start);
        c = sprintf('%s ',allNames{ix});
    end % doExpand()


logList = regexp(Blk,'\<[a-zA-Z]\w*\>','match');
nFlagged = length(logList);
invalid = false(size(logList));
for iFlagged = 1 : nFlagged
    name = logList{iFlagged};
    ix = strcmp(name,allNames);
    if any(ix)
        allLog(ix) = ~default;
    else
        invalid(iFlagged) = true;
    end 
end

InvalidLog = logList(invalid);
if any(invalid)
    InvalidLog = unique(InvalidLog);
end

for is = 1 : length(Loggable)
    nName = length(Loggable(is).name);
    Loggable(is).IxLog(:) = allLog(1:nName);
    allLog(1:nName) = [];
end

end
