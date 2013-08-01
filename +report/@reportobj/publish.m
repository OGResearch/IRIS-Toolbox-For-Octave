function [OutputFile,Count] = publish(This,OutputFile,varargin)
% publish  Help provided in +report/publish.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% The following options passed down to latex.compilepdf:
% * `'cd='`
% * `'display='`
% * `'rerun='`
% and we need to capture them in output varargin.
[opt,compilePdfOpt] = passvalopt('report.publish',varargin{:});
This.options.progress = opt.progress;

if isempty(strfind(opt.papersize,'paper'))
    opt.papersize = [opt.papersize,'paper'];
end

if ~isequal(opt.title,Inf)
    utils.warning('report', ...
        ['The option ''title='' is obsolete in report/publish(), ', ...
        'and will be removed from future versions of IRIS. ', ...
        'Use the Caption input argument in report/new() instead.']);
    This.caption = opt.title;
end

% Obsolete options.
This.options = dbmerge(This.options,opt);

%--------------------------------------------------------------------------

% Create the temporary directory.
doCreateTempDir();

% Get the list of extra packages that needs to be loaded by LaTeX.
pkg = {};
doGetListOfPkg();

thisDir = fileparts(mfilename('fullpath'));
templateFile = fullfile(thisDir,'report.tex');

% Pass the publish options on to the report object and align objects
% either of which can be a parent of figure.
[reportCode,tempFiles] = latexcode(This);
c = file2char(templateFile);
c = strrep(c,'$document$',reportCode);
c = xxDocument(This,c,pkg);

% Create a temporary tex name and save the LaTeX file.
latexFileName = '';
doSaveLatexFile();

[outputPath,outputTitle,outputExt] = fileparts(OutputFile);
if isempty(outputExt)
    OutputFile = fullfile(outputPath,[outputTitle,'.pdf']);
end

if opt.compile
    doCompile();
end

cleanup(This,latexFileName,tempFiles);

% Nested functions.

%**************************************************************************
    function doGetListOfPkg()
        pkg = This.options.package;
        if ischar(pkg)
            pkg = regexp(pkg,'\w+','match');
        end
        if This.longTable
            pkg{end+1} = 'longtable';
        end
    end % doGetListOfPkg().

%**************************************************************************
    function doCreateTempDir()
        % Assign the temporary directory name property.
        if isfunc(opt.tempdir)
            This.tempDirName = opt.tempdir();
        else
            This.tempDirName = opt.tempdir;
        end
        % Try to create the temp dir.
        if ~exist(This.tempDirName,'dir')
            status = mkdir(This.tempDirName);
            if ~status
                utils.error('report', ...
                    'Cannot create temporary directory ''%s''.', ...
                    This.tempDirName);
            end
        end
    end % doCreateTempDir().

%**************************************************************************
    function doSaveLatexFile()
        latexFileName = [tempname(This.tempDirName),'.tex'];
        char2file(c,latexFileName);
    end % doSaveLatexFile().

%**************************************************************************
    function doCompile()
        % Use try-catch to make sure the helper files are deleted at the
        % end of `publish`.
        try
            [pdfName,Count] = ...
                latex.compilepdf(latexFileName,compilePdfOpt{:});
            movefile(pdfName,OutputFile);
        catch Error
            msg = regexprep(Error.message,'\s+',' ');
            if ~isempty(strfind(msg,'The process cannot access'))
                cleanup(This,latexFileName,tempFiles);
                utils.error('report', ...
                    ['Cannot create ''%s'' file because ', ...
                    'the file used by another process ', ...
                    '-- most likely open and locked.'], ...
                    OutputFile);
            else
                utils.warning('report', ...
                    ['Error compiling LaTeX and/or PDF files.\n', ...
                    '\tMatlab says: %s'],msg);
            end
        end
    end % doCompile().

end

% Subfunctions.

%**************************************************************************
function Doc = xxDocument(This,Doc,Pkg)

opt = This.options;

if nargin < 3
    Pkg = {};
end

br = sprintf('\n');

try
    tempTitle = latex.stringsubs(This.title);
    tempSubtitle = latex.stringsubs(This.subtitle);
    tempHead = tempTitle;
    if ~isempty(tempSubtitle)
        if ~isempty(tempTitle)
            tempTitle = [tempTitle,' \\ '];
            tempHead = [tempHead,' / '];
        end
        tempTitle = [tempTitle,'\mdseries ',tempSubtitle];
        tempHead = [tempHead,tempSubtitle];
    end
    if ~isempty(This.options.footnote)
        titleFootnote = ['\footnote{', ...
            latex.stringsubs(This.options.footnote), ...
            '}'];
    else
        titleFootnote = '';
    end
    Doc = strrep(Doc,'$title$',tempTitle);
    Doc = strrep(Doc,'$titlefootnote$',titleFootnote);
catch
    Doc = strrep(Doc,'$title$','');
    Doc = strrep(Doc,'$titlefootnote$','');
end

try
    tempHead = strrep(tempHead,'\\',' / ');
    tempHead = latex.stringsubs(tempHead);
    Doc = strrep(Doc,'$headertitle$',tempHead);
catch
    Doc = strrep(Doc,'$headertitle$','');
end

try
    Doc = strrep(Doc,'$author$',opt.author);
catch
    Doc = strrep(Doc,'$author$','');
end

try
    Doc = strrep(Doc,'$date$',opt.date);
catch
    Doc = strrep(Doc,'$date$','');
end

try
    Doc = strrep(Doc,'$papersize$',opt.papersize);
catch %#ok<*CTCH>
    Doc = strrep(Doc,'$papersize$','');
end

try
    Doc = strrep(Doc,'$orientation$',opt.orientation);
catch
    Doc = strrep(Doc,'$orientation$','');
end

try
    if isa(opt.timestamp,'function_handle')
        opt.timestamp = opt.timestamp();
    end
    Doc = strrep(Doc,'$headertimestamp$',opt.timestamp);
catch
    Doc = strrep(Doc,'$headertimestamp$','');
end

try
    Doc = strrep(Doc,'$textscale$',sprintf('%g',opt.textscale));
catch
    Doc = strrep(Doc,'$textscale$','0.75');
end

try
    Doc = strrep(Doc,'$graphwidth$',opt.graphwidth);
catch
    Doc = strrep(Doc,'$graphwidth$','4in');
end

try
    Doc = strrep(Doc,'$fontencoding$',opt.fontenc);
catch
    Doc = strrep(Doc,'$fontencoding$','T1');
end

try
    Doc = strrep(Doc,'$preamble$',opt.preamble);
catch
    Doc = strrep(Doc,'$preamble$','');
end

try
    if ~isempty(Pkg)
        pkgStr = sprintf('\n\\usepackage{%s}',Pkg{:});
        Doc = strrep(Doc,'$packages$',pkgStr);
    else
        Doc = strrep(Doc,'$packages$','');
    end
catch
    Doc = strrep(Doc,'$packages$','');
end

try
    c = sprintf('%g,%g,%g',opt.highlightcolor);
    Doc = strrep(Doc,'$highlightcolor$',c);
catch
    Doc = strrep(Doc,'$highlightcolor$','0.9,0.9,0.9');
end

try
    if opt.maketitle
        repl = '\maketitle\thispagestyle{empty}';
    else
        repl = '';
    end
catch
    repl = '';
end
Doc = strrep(Doc,'$maketitle$',repl);


if opt.maketitle
    try
        if ~isempty(opt.abstract)
            file = file2char(opt.abstract);
            file = strfun.converteols(file);
            repl = [ ...
                '{\centering', ...
                '\begin{minipage}{$abstractwidth$\textwidth}',br, ...
                '\begin{abstract}\medskip',br,...
                file,br,...
                '\par\end{abstract}',br, ...
                '\end{minipage}',br, ...
                '\par}', ...
                ];
            repl = strrep(repl,'$abstractwidth$', ...
                sprintf('%g',opt.abstractwidth));
        else
            repl = '';
        end
    catch
        repl = '';
    end
end
Doc = strrep(Doc,'$abstract$',repl);

try
    if opt.maketitle
        repl = '\clearpage';
    else
        repl = '';
    end
catch
    repl = '';
end
Doc = strrep(Doc,'$clearfirstpage$',repl);

end % xxDocument().