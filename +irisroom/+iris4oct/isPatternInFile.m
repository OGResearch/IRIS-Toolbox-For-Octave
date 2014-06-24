function [flag, matchedLines] = isPatternInFile (filename, pattern)

flag = false;

fid = fopen(filename,'r+');

tline = ''; %#ok<NASGU>
matchedLines = {};
while ~feof(fid)
    tline = fgetl(fid);
    out = regexp(tline,pattern,'once');
    if ~isempty(out)
        flag = true;
        matchedLines = [matchedLines;tline]; %#ok<AGROW>
    end
end

fclose(fid);