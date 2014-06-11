function T = publishall(varargin)

onlyFiles = {};
onlyFolders = {};
for i = 1 : length(varargin)
    tok = regexp(varargin{i},'(\w+)/(\w+)','tokens','once');
    if isempty(tok) || isempty(tok{1}) || isempty(tok{2})
        continue
    end
    onlyFolders{end+1} = tok{1}; %#ok<AGROW>
    onlyFiles{end+1} = varargin{i}; %#ok<AGROW>
end
onlyFolders = unique(onlyFolders);
onlyFiles = unique(onlyFiles);

helpDir = fullfile(irisroot(),'-help');

T = irisroom.climbtree();

br = sprintf('\n');

texContents = '';
helpToc = '';

ref = 'Contents/index';
irisroom.pandoc('chapter',T,ref);

[chapter,nChapter] = irisroom.branchnames(T);

for k = nChapter : -1 : 1

    ch = T.(chapter{k});
    
    ref = ['Contents/',chapter{k}];
    irisroom.pandoc('chapter',ch,ref);
    
    texContents = [texContents,'\clearpage']; %#ok<AGROW>
    texContents = [texContents,br,'\include{',ref,'}']; %#ok<AGROW>
    helpToc = [helpToc,br, ...
        sprintf('<tocitem target="%s.html" image="HelpIcon.USER_GUIDE">%s', ...
        ref,ch.DESCRIPT)]; %#ok<AGROW>
    
    [folder,nFolder] = irisroom.branchnames(ch);
    
    for i = nFolder : -1 : 1
        
        fo = T.(chapter{k}).(folder{i});

        % Create individual TeX and HTML files for individual m-files. The order in
        % which they appear in the final document is determined later, when
        % compiling the table of contents.
        if isempty(onlyFolders) || any(strcmpi(onlyFolders,folder{i}))
            irisroom.publishfolder(folder{i},fo,onlyFiles);
        end
        
        ref = [folder{i},'/Contents'];
        texContents = [texContents,br,'    \clearpage']; %#ok<AGROW>
        texContents = [texContents,br,'    \input{',ref,'}']; %#ok<AGROW>
        helpToc = [helpToc,br, ...
            sprintf('    <tocitem target="%s.html" image="HelpIcon.FUNCTION">%s', ...
            ref,fo.DESCRIPT)]; %#ok<AGROW>
        
        [file,nFile] = irisroom.branchnames(fo,'sort');

        % Compile the table of contents and determine the order of appearance for
        % the individual files in each folder.
        for j = 1 : nFile
            fi = T.(chapter{k}).(folder{i}).(file{j});
            ref = [folder{i},'/',file{j}];
            texContents = [texContents,br,'         \input{',ref,'}']; %#ok<AGROW>
            
            syntax = strrep(fi.SYNTAX,'&','&amp;');
            syntax = strrep(syntax,'<','&lt;');
            syntax = strrep(syntax,'>','&gt;');
            
            helpToc = [helpToc,br, ...
                sprintf('        <tocitem target="%s.html">%s &#8212; %s</tocitem>', ...
                ref,syntax,fi.DESCRIPT)]; %#ok<AGROW>
        end
        
        helpToc = [helpToc,br,'    </tocitem>']; %#ok<AGROW>
        
    end
    
    helpToc = [helpToc,br,'</tocitem>']; %#ok<AGROW>
end
helpToc = [helpToc,br];

% Update Contents.tex.
texcontentsfile = fullfile(helpDir,'Contents.tex');
char2file(texContents,texcontentsfile);

% Update helptoc.xml.
helptocfile = fullfile(helpDir,'helptoc.xml');
h = file2char(helptocfile);
h = regexprep(h,'<!-- START -->.*?<!-- END -->', ...
    ['<!-- START -->',helpToc,'<!-- END -->'],'once');
char2file(h,helptocfile);

% Update IRIS version in IRIS_Man.tex.
version = datestr(now(),'yyyymmdd');
manfile = fullfile(helpDir,'IRIS_Man.tex');
c = file2char(manfile);
c = regexprep(c,'\\newcommand\{\\irisversion\}\{.*?\}', ...
    ['\\newcommand\{\\irisversion\}\{',version,'\}']);
char2file(c,manfile);

% Publish manual to PDF and make a copy in the IRIS_Archive folder.
latex.compilepdf(manfile);
manPdf = strrep(manfile,'.tex','.pdf');
copyfile(manPdf,['/Users/myself/IRIS/Archive/IRIS_Man_',version,'.pdf']);

% Delete auxiliary files.
delete(fullfile(helpDir,'IRIS_Man.aux'));
delete(fullfile(helpDir,'IRIS_Man.log'));
delete(fullfile(helpDir,'IRIS_Man.synctex.gz'));

end