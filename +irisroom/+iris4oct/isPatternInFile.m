function [flag, matchedLines] = isPatternInFile (filename, pattern, nforward)

if nargin<3
    nforward = 0;
end

flag = false;

fid = fopen(filename,'r+');

tline = ''; %#ok<NASGU>
matchedLines = struct('str',{},'n',[]);
n = 1;
while ~feof(fid)
    tline = fgetl(fid);
    out = regexp(tline,pattern,'once');
    if ~isempty(out)
        spos = ftell(fid);
        flag = true;
        if isempty(matchedLines)
            matchedLines(1).str = {tline};
            matchedLines(1).n = n;
            matchedLines(1).fwd = {{}};
        else
            matchedLines.str = [matchedLines.str;tline];
            matchedLines.n = [matchedLines.n;n];
            matchedLines.fwd{end+1} = {};
        end
        fwline = '';
        for i = 1 : nforward
            fwline = fgetl(fid);
            matchedLines.fwd{end} = [matchedLines.fwd{end};fwline];
        end
        fseek(fid,spos,'bof');
    end
    n = n + 1;
end

fclose(fid);