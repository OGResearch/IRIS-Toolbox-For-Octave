function publish(InpFile,OutpFile,varargin)
% publish  Publish m-file or model file to PDF.
%
% Syntax
% =======
%
%     latex.publish(InpFile)
%     latex.publish(InpFile,[],...)
%     latex.publish(InpFile,OutpFile,...)
%
% Input arguments
% ================
%
% * `InpFile` [ char | cellstr ] - Input file name; can be either an
% m-file, a model file, or a cellstr combining a number of them.
%
% * `OutpFile` [ char ] - Output file name; if omitted or empty, the
% output file name will be derived from the input file by adding a pdf
% extension.
%
% Options
% ========
%
% --General options
%
% * `'cleanup='` [ *`true`* | `false` ] - Delete all temporary files
% (LaTeX and eps) at the end.
%
% * `'closeAll='` [ *`true`* | `false` ] - Close all figure windows at the
% end.
%
% * `'display='` [ *`true`* | `false` ] - Display pdflatex compiler report.
%
% * `'evalCode='` [ *`true`* | `false` ] - Evaluate code when publishing the
% file; the option is only available with m-files.
%
% * `'useNewFigure='` [ `true` | *`false`* ] - Open a new figure window for each
% graph plotted.
%
% --Content-related options
%
% * `'author='` [ char | *empty* ] - Author that will be included on the
% title page.
%
% * `'date='` [ char | *'\today' ] - Publication date that will be included
% on the title page.
%
% * `'event='` [ char | *empty* ] - Event (conference, workshop) that will
% be included on the title page.
%
% * `'figureScale='` [ numeric | *1* ] - Factor by which the graphics
% will be scaled.
%
% * `'irisVersion='` [ *`true`* | `false` ] - Display the current IRIS version
% in the header on the title page.
%
% * `'lineSpread='` [ numeric | *'auto'*] - Line spacing.
%
% * `'matlabVersion='` - Display the current Matlab version in the header on
% the title page.
%
% * `'numbered='` - [ *`true`* | `false` ] - Number sections.
%
% * `'package='` - [ cellstr | char | *'inconsolata'* ] - List of packages
% that will be loaded in the preamble.
%
% * `'paperSize='` -  [ 'a4paper' | *'letterpaper'* ] - Paper size.
%
% * `'preamble='` - [ char | *empty* ] - LaTeX commands
% that will be included in the preamble of the document.
%
% * `'template='` - [ *'paper'* | 'present' ] - Paper-like or
% presentation-like format.
%
% * `'textScale='` - [ numeric | *0.70* ] - Proportion of the paper used for
% the text body.
%
% * `'toc='` - [ *`true`* | `false` ] - Include the table of contents.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    OutpFile; %#ok<VUNUS>
catch
    OutpFile = [];
end

opt = passvalopt('latex.publish',varargin{:});

if opt.toc && ~opt.numbered
    utils.error('latex', ...
        'Options ''numbered'' and ''toc'' are used inconsistently.');
end

if ischar(InpFile)
    InpFile = regexp(InpFile,'[^,;]+','match');
end
nInput = length(InpFile);

texFile = cell(1,nInput);
inputExt = cell(size(InpFile));
inputTitle = cell(size(InpFile));
for i = 1 : nInput
    [inputPath,inputTitle{i},inputExt{i}] = fileparts(InpFile{i});
    texFile{i} = [inputTitle{i},'.tex'];
    if i == 1 && isempty(OutpFile)
        OutpFile = fullfile(inputPath,[inputTitle{i},'.pdf']);
    end
    if isempty(inputExt{i})
        inputExt{i} = '.m';
    end
end

% Old option name.
if ~isempty(opt.deletetempfiles)
    opt.cleanup = opt.deletetempfiles;
end

%--------------------------------------------------------------------------

br = sprintf('\n');

switch lower(opt.template)
    case 'paper'
        template = file2char(fullfile(irisroot(),'+latex','paper.tex'));
        if ~isnumericscalar(opt.linespread)
            opt.linespread = 1.1;
        end
    case 'present'
        template = file2char(fullfile(irisroot(),'+latex','present.tex'));
        if ~isnumericscalar(opt.linespread)
            opt.linespread = 1;
        end
        opt.toc = false;
    otherwise
        template = file2char(opt.template);
        if ~isnumericscalar(opt.linespread)
            opt.linespread = 1;
        end
end
template = strfun.converteols(template);

thisDir = pwd();
wDir = mosw.tempname(thisDir);
mkdir(wDir);

% Run input files with compact spacing.
if false % ##### MOSW
    spacing = get(0,'formatSpacing');
    set(0,'formatSpacing','compact');
end
% Create mfile2xml (publish) options. The output directory is assumed to
% always coincide with the input file directory.
mfile2xmloptions = struct( ...
    'format','xml', ...
    'outputDir',wDir, ...
    ... 'imageDir',wdir, ...
    'imageFormat','epsc2', ...
    'evalCode',opt.evalcode, ...
    'useNewFigure',opt.usenewfigure);

% Try to copy all tex files to the working directory in case there are
% \input or \include commands.
try %#ok<TRYNC>
    copyfile('*.tex',wDir);
end

% Loop over all input files and produce XMLDOMs.
xmlDoc = cell(1,nInput);
for i = 1 : nInput
    copy = xxPrepareToPublish([inputTitle{i},inputExt{i}]);
    % Only m-files can be published with `'evalCode='` true.
    if isequal(inputExt{i},'.m')
        mfile2xmloptions.evalCode = opt.evalcode;
    else
        mfile2xmloptions.evalCode = false;
    end
    % Switch off warnings produced by the built-in publish when conversion
    % of latex equations to images fails.
    ss = warning();
    warning('off');%#ok<WNOFF>
    % Publish an xml file and read the file in again as xml object.
    xmlFile = publish([inputTitle{i},inputExt{i}],mfile2xmloptions);
    warning(ss);
    xmlDoc{i} = xmlread(xmlFile);
    char2file(copy,[inputTitle{i},inputExt{i}]);
end

% Reset spacing.
if false % ##### MOSW
    set(0,'formatSpacing',spacing);
end

% Switch to the working directory so that `xml2tex` can find the graphics
% files.
cd(wDir);
try
    tex = cell(1,nInput);
    body = '';
    for i = 1 : nInput
        if nInput == 1
            type = 'single';
        elseif i == 1
            type = 'master';
        else
            type = 'multiple';
        end
        [tex{i},author,event] = latex.xml.xml2tex(xmlDoc{i},type,opt);
        if isempty(opt.author) && i == 1 && ischar(author)
            opt.author = author;
        end
        if isempty(opt.author) && i == 1 && ischar(event)
            opt.event = event;
        end
        tex{i} = xxDocSubs(tex{i},opt);
        char2file(tex{i},texFile{i});
        body = [body,'\input{',texFile{i},'}',br]; %#ok<AGROW>
    end
    
    template = strrep(template,'$body$',body);
    template = xxDocSubs(template,opt);
    
    char2file(template,'main.tex');
    latex.compilepdf('main.tex');
    copyfile('main.pdf',OutpFile);
    movefile(OutpFile,thisDir);
catch Error
    utils.warning('latex:publish', ...
        ['Error producing PDF.\n', ...
        '\tUncle says: %s'], ...
        Error.message);
end

while ~isequal(pwd(),thisDir)
    cd(thisDir);
end
if opt.cleanup
    rmdir(wDir,'s');
end

if opt.closeall
    close('all');
end

end


% Subfunctions...


%**************************************************************************


function C = xxDocSubs(C,Opt)
br = sprintf('\n');
C = strrep(C,'$papersize$',Opt.papersize);

% Author.
Opt.author = strtrim(Opt.author);
if ischar(Opt.author) && ~isempty(Opt.author)
    C = strrep(C,'$author$',['\byauthor ',Opt.author]);
elseif ischar(Opt.event) && ~isempty(Opt.event)
    C = strrep(C,'$author$',['\atevent ',Opt.event]);
else
    C = strrep(C,'$author$','');
end

C = strrep(C,'$date$',Opt.date);
C = strrep(C,'$textscale$',sprintf('%g',Opt.textscale));
C = strrep(C,'$figurescale$',sprintf('%g',Opt.figurescale));
if Opt.matlabversion
    v = version();
    v = strrep(v,' ','');
    v = regexprep(v,'(.*)\s*\((.*?)\)','$2');
    C = strrep(C,'$matlabversion$', ...
        ['Matlab: ',v]);
else
    C = strrep(C,'$matlabversion$','');
end

if Opt.irisversion
    C = strrep(C,'$irisversion$', ...
        ['IRIS: ',irisversion()]);
else
    C = strrep(C,'$irisversion$','');
end

% Packages.
if ~isempty(Opt.package)
    c1 = '';
    if ischar(Opt.package)
        Opt.package = {Opt.package};
    end
    npkg = length(Opt.package);
    for i = 1 : npkg
        pkg = Opt.package{i};
        if isempty(strfind(pkg,'{'))
            c1 = [c1,'\usepackage{',pkg,'}']; %#ok<AGROW>
        else
            c1 = [c1,'\usepackage',pkg]; %#ok<AGROW>
        end
        c1 = [c1,br]; %#ok<AGROW>
    end
    C = strrep(C,'$packages$',c1);
else
    C = strrep(C,'$packages$','');
end

C = strrep(C,'$preamble$',Opt.preamble);
if Opt.numbered
    C = strrep(C,'$numbered$','');
else
    C = strrep(C,'$numbered$','*');
end
linespread = sprintf('%g',Opt.linespread);
C = strrep(C,'$linespread$',linespread);
end % xxDocSubs()


%**************************************************************************


function Copy = xxPrepareToPublish(File)
% xxpreparetopublish  Remove formats not recognised by built-in publish.
c = file2char(File);
Copy = c;
% Replace %... and %%% with %%% ...
c = regexprep(c,'^%[ \t]*\.\.\.\s*$','%% ...','lineanchors');
c = regexprep(c,'^%%%[ \t]*(?=\n)$','%% ...','lineanchors');
% Remove underlines % ==== with 4+ equal signs.
c = regexprep(c,'^% ?====+','%','lineanchors');
% Remove underlines % ---- with 4+ equal signs.
c = regexprep(c,'^% ?----+','%','lineanchors');
% Replace ` with |.
c = strrep(c,'`','|');
char2file(c,File);
end % xxPrepareToPublish()
