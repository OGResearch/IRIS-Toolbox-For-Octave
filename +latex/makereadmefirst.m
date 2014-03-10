function makereadmefirst()
% makereadmefirst  Populate the read_me_first.m file based on tutorial files.

br = sprintf('\n');

% A read_me_first.m must exist, with exactly one tutorial file included in
% each section code. The first, second, and last sections are special.
c = file2char('read_me_first.m');
c = strfun.converteols(c);

% Split the read_me_first.m file into code sections.
start = regexp(c,'^%%(?!%)','start','lineanchors');
nSect = length(start);
sect = cell(1,nSect);
start = [start,length(c)+1];
for i = 1 : nSect
    sect{i} = c(start(i):start(i+1)-1);
end

% First section does not change...

% Second section is How to Run...
sect{2} = file2char(fullfile(irisroot(),'+latex','howtorun.m'));

fileList = {};
for i = 3 : nSect-1
    s = sect{i};
    s = strfun.removecomments(s,'%',{'%{','%}'});
    s = regexprep(s,'edit [^\n]+','');
    file = regexp(s,'\w+','match');
    ci = sprintf('%g',i);
    if isempty(file)
        utils.error('latex:makereadmefirst', ...
            'No m-file names in section #%s.',ci);
    elseif length(file) > 1
        utils.error('latex:makereadmefirst', ...
            ['Multiple m-file names in section #',ci,': ''%s''.'], ...
            file{:});
    end
    file = file{1};
    intro = latex.mfile2intro(file);
    intro = regexprep(intro,'^%[ ]*[Bb]y.*?\n','','once','lineanchors');
    % Add two lines:
    % * % edit filename.m;
    % * filename;
    sect{i} = [intro,br,br, ...
        '% edit ',file,'.m;',br, ...
        file,';'];
    fileList{end+1} = file; %#ok<AGROW>
end

% Last section is Publish M-Files to PDFs...
e = file2char(fullfile(irisroot(),'+latex','howtopublish.m'));
for i = 1 : length(fileList)
    e = [e,br,'%     latex.publish(''',fileList{i},'.m'');']; %#ok<AGROW>
end
sect{end} = e;

% Make sure there are exactly two line breaks at the end of each section,
% and one line break at the end of the file.
for i = 1 : nSect
    sect{i} = regexprep(sect{i},'\n+$','');
    sect{i} = [sect{i},br];
    if i < nSect
        sect{i} = [sect{i},br]; 
    end
end

c = [sect{:}];
char2file(c,'read_me_first.m');

end
