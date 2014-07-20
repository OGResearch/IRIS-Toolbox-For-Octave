function [OutpFile,Info] = publish(This,OutpFile,varargin)
% publish  Help provided in +report/publish.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% The following options passed down to latex.compilepdf:
% * `'cd='` (obsolete)
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

thisDir = fileparts(mfilename('fullpath'));
templateFile = fullfile(thisDir,'report.tex');

% Pass the publish options on to the report object and align objects
% either of which can be a parent of figure.
c = file2char(templateFile);

% Create LaTeX code for the entire report.
doc = latexcode(This);

% Get the list of extra packages that needs to be loaded by LaTeX.
pkg = {};
doExtraPkg();

% Insert the LaTeX code into the template.
c = strrep(c,'$document$',doc);
c = xxDocument(This,c,pkg);


% Create a temporary tex name and save the LaTeX file.
latexFile = '';
doSaveLatexFile();

[outputPath,outputTitle,outputExt] = fileparts(OutpFile);
if isempty(outputExt)
    OutpFile = fullfile(outputPath,[outputTitle,'.pdf']);
end

if opt.compile
    doCompile();
end

[latexPath,latexTitle] = fileparts(latexFile);
addtempfile(This,fullfile(latexPath,[latexTitle,'.*']));

if opt.cleanup
    cleanup(This);
end

% Copy output information fields to a struct.
Info = outpstruct(This.hInfo);


% Nested functions...


%**************************************************************************


    function doExtraPkg()
        pkg = This.options.package;
        if ischar(pkg)
            pkg = regexp(pkg,'\w+','match');
        end
        list = fieldnames(This.hInfo.package);
        for i = 1 : length(list)
            name = list{i};
            if This.hInfo.package.(name)
                pkg{end+1} = name; %#ok<AGROW>
            end
        end
        
    end % doExtraPkg()


%**************************************************************************

    
    function doCreateTempDir()
        % Assign the temporary directory name property.
        if isfunc(opt.tempdir)
            tempDir = opt.tempdir();
        else
            tempDir = opt.tempdir;
        end
        % Try to create the temp dir.
        if ~exist(tempDir,'dir')
            status = mkdir(tempDir);
            if ~status
                utils.error('report', ...
                    'Cannot create temporary directory ''%s''.', ...
                    tempDir);
            end
        end
        This.hInfo.tempDir = tempDir;
    end % doCreateTempDir()


%**************************************************************************
    
    
    function doSaveLatexFile()
        tempDir = This.hInfo.tempDir;
        latexFile = [tempname(tempDir),'.tex'];
        char2file(c,latexFile);
    end % doSaveLatexFile()


%**************************************************************************


    function doCompile()
        % Use try-catch to make sure the helper files are deleted at the
        % end of `publish`.
        try
            [pdfName,count] = latex.compilepdf(latexFile,compilePdfOpt{:});
            This.hInfo.latexRun = count;
            movefile(pdfName,OutpFile);
        catch Error
            msg = regexprep(Error.message,'\s+',' ');
            if ~isempty(strfind(msg,'The process cannot access'))
                cleanup(This);
                utils.error('report', ...
                    ['Cannot create ''%s'' file because ', ...
                    'the file used by another process ', ...
                    '-- most likely open and locked.'], ...
                    OutpFile);
            else
                utils.warning('report', ...
                    ['Error compiling LaTeX and/or PDF files.\n', ...
                    '\tUncle says: %s'], ...
                    msg);
            end
        end
    end % doCompile()


end


% Subfunctions...


%**************************************************************************


function Doc = xxDocument(This,Doc,Pkg)

opt = This.options;

timeStamp = opt.timestamp;
if isa(timeStamp,'function_handle')
    timeStamp = timeStamp();
end
timeStamp = interpret(This,timeStamp);

if nargin < 3
    Pkg = {};
end

br = sprintf('\n');


try
    tempTitle = interpret(This,This.title);
    tempSubtitle = interpret(This,This.subtitle);
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
            interpret(This,This.options.footnote), ...
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
    Doc = strrep(Doc,'$papersize$',lower(opt.papersize));
catch %#ok<*CTCH>
    Doc = strrep(Doc,'$papersize$','');
end


try
    Doc = strrep(Doc,'$orientation$',lower(opt.orientation));
catch
    Doc = strrep(Doc,'$orientation$','');
end


try
    Doc = strrep(Doc,'$headertimestamp$',timeStamp);
catch
    Doc = strrep(Doc,'$headertimestamp$','');
end


try
    x = opt.textscale;
    if length(x) == 1
        s = sprintf('%g',x);
    else
        s = sprintf('{%g,%g}',x(1),x(2));
    end
    Doc = strrep(Doc,'$textscale$',s);
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


try %#ok<TRYNC>
    if This.hInfo.package.colortbl
        Doc = strrep(Doc,'% $colortbl$','');
    end
end


try
    if opt.maketitle
        repl = ['\date{',timeStamp,'}', ...
            '\maketitle', ...
            '\thispagestyle{empty}'];
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

end % xxDocument()
