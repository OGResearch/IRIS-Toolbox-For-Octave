function Intro = mfile2intro(File)

[~,~,ext] = fileparts(File);
if isempty(ext)
    File = [File,'.m'];
end

c = file2char(File);
c = strfun.converteols(c);

start = regexp(c,'^%%(?!%)','start','lineanchors');

if isempty(start)
    utils.error('latex:mfile2intro', ...
        'No introduction found in %s.', ...
        File);
end

start = [start,length(c)+1];
Intro = c(start(1):start(2)-1);
Intro = regexprep(Intro,'\n+$','');

end