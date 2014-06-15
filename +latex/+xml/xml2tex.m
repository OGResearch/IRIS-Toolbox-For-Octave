function [C,Author,Event] = xml2tex(X,Type,Opt)
% xml2tex  Convert publish XML to TEX code.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% First input can be either a xml dom or a xml file name.
if ischar(X)
    X = xmlread(X);
end

xxOriginalCode(X);
xxBookmarks();

% Overview cell (introduction).
[C,Author,Event] = xxIntroduction(X,Type,Opt);

% Table of contents.
C = [C,xxToc(X,Type,Opt)];

if isequal(Type,'master')
    return
end

% Normal cells.
y = latex.xml.xpath(X,'//cell[not(@style="overview")]','nodeset');
n = y.getLength();
for i = 1 : n
    C = [C,xxNormalCell(y.item(i-1),Type,Opt)];
end

% Fix idiosyncrasies.
C = xxIdiosyncrasy(C);

end


% Subfunctions...


%**************************************************************************
function C = xxBookmarks(B)
persistent bookmarks %typeset;
if nargin == 0 && nargout == 0
    code = xxOriginalCode();
    bookmarks = regexp(code,'%\?(\w+)\?','tokens');
    bookmarks = [bookmarks{:}];
    [~,inx] = unique(bookmarks,'first');
    bookmarks = bookmarks(sort(inx));
    %nbkm = length(bookmarks);
    %typeset = xxBookmarkTypeset();
    %typeset = typeset(1:nbkm);
    return
end
C = '';
if ischar(B)
    inx = strcmp(B,bookmarks);
    if any(inx)
        C = sprintf('%g',find(inx,1)); % typeset{inx};
    else
        C = '?';
    end
    C = ['\bookmark{',C,'}'];
end
end % xxBookmarks()


%**************************************************************************
function [C,Author,Event] = xxIntroduction(X,Type,Opt)
C = '';
br = sprintf('\n');
[ans,ftit,fext] = ...
    fileparts(latex.xml.xpath(X,'//filename','string')); %#ok<NOANS,ASGLU>
mfilename = [ftit,fext];
[~,~,fext] = fileparts(mfilename);
if isempty(fext)
    mfilename = [mfilename,'.m'];
end
% Read title.
title = latex.xml.xpath(X,'//cell[@style="overview"]/steptitle','node');
title = xxText(title);
title = strtrim(title);
emptytitle = isempty(title);
% Read first paragraph and check if it gives the authors.
Author = NaN;
Event = NaN;
p = latex.xml.xpath(X, ...
    '//cell[@style="overview"]/text/p[position()=1]','node');
if ~isempty(p)
    temp = strtrim(char(p.getTextContent()));
    if strncmp(temp,'by ',3)
        Author = temp(4:end);
        Author = strrep(Author,'&',' \\ ');
        if ~isempty(strfind(Author,' \\ '))
            Author = ['\\ ',Author];
        end
        % Remove the first paragraph.
        p.getParentNode.removeChild(p);
    elseif strncmp(temp,'at ',3)
        Event = temp(4:end);
        % Remove the first paragraph.
        p.getParentNode.removeChild(p);
    end
end
% Read abstract.
abstract = latex.xml.xpath(X,'//cell[@style="overview"]/text','node');
abstract = xxText(abstract);
abstract = strtrim(abstract);
% Read file name.
mfilename = xxSpecChar(mfilename);
switch Type
    case 'single'
        if ~emptytitle
            C = [C, ...
                '\introduction{',title,'}', ...
                '{\mfilenametitle{',mfilename,'}}',br, ...
                ];
        else
            C = [C,'\introduction{',mfilename,'}{}',br];
        end
        if ~isempty(abstract)
            C = [C,'\begin{myabstract}',abstract,'\end{myabstract}',br];
        end
    case 'master'
        if ~emptytitle
            C = [C,'\introduction{',title,'}','{}',br];
        else
            C = [C,'\introduction{',mfilename,'}{}',br];
        end
        if ~isempty(abstract)
            C = [C,'\begin{abstract}',abstract,'\end{abstract}',br];
        end
    case 'multiple'
        C = ['\clearpage',br];
        if emptytitle
            tocentry = title;
        else
            tocentry = [title,' --- \texttt{',mfilename,'}'];
        end
        if Opt.numbered
            C = [C,'\section[',tocentry,']{',title];
        else
            C = [C,'\section*{',title];
        end
        if ~emptytitle
            C = [C,' \mfilenametitle{',mfilename,'}'];
        end
        C = [C,'}',br];
end
if ~isequal(Type,'master')
    C = [C, ...
        '\renewcommand{\filetitle}{',title,'}',br, ...
        '\renewcommand{\mfilename}{',mfilename,'}',br];
    C = [C,br,'\bigskip\par'];
end
C = [C,br,br];
end % xxIntroduction()


%**************************************************************************
function C = xxToc(X,Type,Opt) %#ok<INUSL>
br = sprintf('\n');
C = '';
if ~Opt.toc || isequal(Type,'multiple')
    return
end
if isequal(Type,'master')
    C = [C,'\clearpage',br];
end
C = [C,'\mytableofcontents',br,br];
end
% toc()


%**************************************************************************
function C = xxNormalCell(X,Type,Opt) %#ok<INUSD>
br = sprintf('\n');
title = strtrim(latex.xml.xpath(X,'steptitle','string'));
if isequal(title,'...')
    cBegin = '\begin{splitcell}';
    cEnd = '\end{splitcell}';
else
    cBegin = ['\begin{cell}{',title,'}'];
    cEnd = '\end{cell}';
end
C = '';
% Intro text.
c1 = xxText(latex.xml.xpath(X,'text','node'));
if ~isempty(c1)
    C = [C,'\begin{introtext}',br];
    C = [C,c1,br];
    C = [C,'\end{introtext}',br];
end
% Input code.
y = latex.xml.xpath(X,'mcode','node');
if ~isempty(y)
    inpCode = char(y.getTextContent());
    inpCode = strfun.converteols(inpCode);
    inpCode = strfun.removetrails(inpCode);
    [~,n] = xxOriginalCode(inpCode);
    
    if false % ##### MOSW
        replace = @xxBookmarks; %#ok<NASGU>
        inpCode = regexprep(inpCode,'%\?(\w+)\?', ...
            '`${replace($1)}`');
    else
        inpCode = mosw.dregexprep(inpCode,'%\?(\w+)\?', ...
            @(C1) ['`',xxBookmarks(C1),'`'],1); %#ok<UNRCH>
    end
    
    C = [C,br, ...
        '\begin{inputcode}',br, ...
        '\lstset{firstnumber=',sprintf('%g',n),'}',br, ...
        '\begin{lstlisting}',br, ...
        inpCode, ...
        '\end{lstlisting}',br, ...
        '\end{inputcode}'];
end
% Output code.
outputCode = latex.xml.xpath(X,'mcodeoutput','node');
if ~isempty(outputCode)
    outputCode = char(outputCode.getTextContent());
    outputCode = strfun.converteols(outputCode);
    C = [C,br, ...
        '\begin{outputcode}',br, ...
        '\begin{lstlisting}',br, ...
        outputCode, ...
        '\end{lstlisting}',br, ...
        '\end{outputcode}',br];
end
% Images that are part of code output.
images = latex.xml.xpath(X,'img','nodeset');
nImg = images.getLength();
if nImg > 0
    for iImg = 1 : nImg
        C = [C,xxImg(images.item(iImg-1))];
    end
end
C = [cBegin,br,C,br,cEnd,br,br];
end % xxNormalCell()


%**************************************************************************
function [Code1,N] = xxOriginalCode(X)
persistent code;
try %#ok<TRYNC>
    if ~ischar(X)
        % Initialise `originalcode` when `x` is an xml dom.
        code = latex.xml.xpath(X,'//originalCode','string');
        code = strfun.converteols(code);
        code = strfun.removetrails(code);
    end
end
Code1 = code;
if nargout < 2
    return
end
nCode = length(X);
start = strfind(code,X);
if isempty(start)
    disp(X);
    utils.error('latex', ...
        'The above m-file code segment not found.');
end
start = start(1);
finish = start + nCode - 1;
N = sum(code(1:start-1) == char(10)) + 1;
nReplace = sum(X == char(10));
replace = char(10*ones(1,nReplace));
code = [code(1:start-1),replace,code(finish+1:end)];
end % xxOriginalCode()


%**************************************************************************
function C = xxText(X)
C = '';
if isempty(X)
    return
end
br = sprintf('\n');
X = latex.xml.xpath(X,'node()','nodeset');
n = X.getLength();
for i = 1 : n
    this = X.item(i-1);
    switch char(this.getNodeName)
        case 'latex'
            c1 = char(this.getTextContent());
            c1 = strrep(c1,'<latex>','');
            c1 = strrep(c1,'</latex>','');
            C = [C,br,br,c1,br]; %#ok<*AGROW>
        case 'p'
            % Paragraph.
            C = [C,br,'\begin{par}',xxText(this), ...
                '\end{par}'];
        case 'a'
            % Bookmark in the text.
            c1 = char(this.getTextContent());
            if ~isempty(c1) && all(c1([1,end]) == '?')
                c1 = xxBookmarks(c1(2:end-1));
            else
                c1 = xxText(this);
                c1 = ['\texttt{\underline{',c1,'}}'];
            end
            C = [C,c1];
        case 'b'
            C = [C,'\textbf{',xxText(this),'}'];
        case 'i'
            C = [C,'\textit{',xxText(this),'}'];
        case 'tt'
            C = [C,'{\codesize\texttt{',xxText(this),'}}'];
        case 'ul'
            C = [C,'\begin{itemize}',xxText(this), ...
                '\end{itemize}'];
        case 'ol'
            C = [C,'\begin{enumerate}',xxText(this), ...
                '\end{enumerate}'];
        case 'li'
            c1 = strtrim(xxText(this));
            n = length('\bookmark{');
            if strncmp(c1,'\bookmark{',n)
                % Item starting with a bookmark.
                close = strfun.matchbrk(c1,n);
                if isempty(close)
                    close = 0;
                end
                C = [C,'\item[',c1(1:close),'] ',c1(close+1:end)];
            else
                % Regular item.
                C = [C,'\item ',c1];
            end
        case 'pre'
            % If this is a <pre class="error">, do not display
            % anything.
            if ~strcmp(char(this.getAttribute('class')),'error')
                c1 = char(this.getTextContent());
                C = [C,'{\codesize\begin{verbatim}',c1, ...
                    '\end{verbatim}}'];
            end
        case 'img'
            % This is an equation converted successfully to an image.
            % Retrieve the original latex code from the attribute alt.
            % We do not need to capture the name of the source image
            % because it is inside the temp directory, and will be
            % deleted at the end.
            if strcmp(char(this.getAttribute('class')),'equation')
                alt = char(this.getAttribute('alt'));
                C = [C,alt]; %#ok<AGROW>
            end
        case 'equation'
            % An equation element either contains a latex code directly
            % (if conversion to image failed), or an image element.
            c1 = char(this.getTextContent());
            c1 = strtrim(c1);
            if isempty(c1)
                % Image element.
                c1 = xxText(this);
                c1 = strtrim(c1);
            end
            C = [C,c1]; %#ok<AGROW>
        otherwise
            c1 = char(this.getTextContent());
            c1 = regexprep(c1,'\s+',' ');
            c1 = xxSpecChar(c1);
            C = [C,c1]; %#ok<AGROW>
    end
end
end % xxText()


%**************************************************************************
function C = xxIdiosyncrasy(C)
C = strrep(C,'\end{itemize}\begin{itemize}','');
C = strrep(C,'\end{enumerate}\begin{enumerate}','');
end % xxIdiosyncrasy()


%**************************************************************************
function C = xxImg(X)
% File name in the `src` attribute is a relative path wrt the original
% directory. We only need to refer to the file name.
fName = latex.xml.xpath(X,'@src','string');
[~,fTitle,fExt] = fileparts(fName);
C = '';
if ~exist([fTitle,fExt],'file')
    utils.warning('xml', ...
        'Image file not found: ''%s''.',[fTitle,fExt]);
    return
end
if isequal(fExt,'.eps')
    latex.epstopdf([fTitle,fExt]);
    fExt = '.pdf';
end
br = sprintf('\n');
C = [br,'{\centering', ...
    br,'\includegraphics[scale=$figurescale$]{',[fTitle,fExt],'}', ...
    br,'\par}'];
end % xxImg()


%**************************************************************************
function C = xxSpecChar(C)
C = strrep(C,'\','\textbackslash ');
C = strrep(C,'_','\_');
C = strrep(C,'%','\%');
C = strrep(C,'$','\$');
C = strrep(C,'#','\#');
C = strrep(C,'&','\&');
C = strrep(C,'<','\ensuremath{<}');
C = strrep(C,'>','\ensuremath{>}');
C = strrep(C,'~','\ensuremath{\sim}');
C = strrep(C,'^','\^{ }');
end %xxSpecChar()


%**************************************************************************
%{
function X = xxBookmarkTypeset()

persistent B

if ~isempty(B)
    X = B;
    return
end

B = {};
for i = 1 : 99
    B{end+1,1} = sprintf('%g',i);
end
for i = 97 : 122
    B{end+1,1} = char(i);
end

B = [B;{ ...
    '$\alpha$'
    '$\beta$'
    '$\gamma$'
    '$\delta$'
    '$\epsilon$'
    '$\zeta$'
    '$\eta$'
    '$\theta$'
    '$\iota$'
    '$\kappa$'
    '$\lambda$'
    '$\mu$'
    '$\nu$'
    '$\xi$'
    '$\pi$'
    '$\varrho$'
    '$\sigma$'
    '$\tau$'
    '$\upsilon$'
    '$\phi$'
    '$\chi$'
    '$\psi$'
    '$\omega$'
    '$\Gamma$'
    '$\Delta$'
    '$\Theta$'
    '$\Lambda$'
    '$\Xi$'
    '$\Pi$'
    '$\Sigma$'
    '$\Upsilon$'
    '$\Phi$'
    '$\Psi$'
    '$\Omega$'
    }];
X = B;

end % xxBookmarkTypeset()
%}