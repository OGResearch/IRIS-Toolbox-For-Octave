function [flag, matchedLines] = isPatternInFile (filename, pattern)

flag = false;

fid = fopen(filename,'r+');

tline = ''; %#ok<NASGU>
matchedLines = struct('str',{},'n',[]);
n = 1;
while ~feof(fid)
    tline = fgetl(fid);
    out = regexp(tline,pattern,'once');
    if ~isempty(out)
        flag = true;
        if isempty(matchedLines)
            matchedLines(1).str = {tline};
            matchedLines(1).n = n;
        else
            matchedLines.str = [matchedLines.str;tline];
            matchedLines.n = [matchedLines.n;n];
        end
    end
    n = n + 1;
end

fclose(fid);