function [TEX,HTML] = pandoc(LEVEL,X,REF)

c = X.HELPTEXT;
c = strfun.converteols(c);

tempFile = [tempname(),'.txt'];
templateFile = fullfile(irisroot(),'+irisroom','helptemplate');

pandoc = [ ...
    ... '"C:\Program Files (x86)\Pandoc\bin\pandoc" ', ...
    '/usr/local/bin/pandoc ', ...
    '--base-header-level=4 ',...
    '--from=markdown ', ...
    '--to=$TO$ ', ...
    '--variable=$LEVEL$:1 ',...
    '--variable=SYNTAX:"$SYNTAX$" ', ...
    '--variable=DESCRIPT:"$DESCRIPT$" ', ...
    '--variable=REF:"$REF$" ', ...
    '--template=',templateFile,' ', ...
    '--latexmathml ', ... 
    '"',tempFile,'"'];

% Create pandoc variables.
pandoc = strrep(pandoc,'$LEVEL$',upper(LEVEL));
pandoc = strrep(pandoc,'$DESCRIPT$',X.DESCRIPT);
pandoc = strrep(pandoc,'$REF$',REF);

pandoctex = strrep(pandoc,'$TO$','latex');
pandochtml = strrep(pandoc,'$TO$','html');

% The variable SYNTAX must be formatted for latex because it can contain
% characters %, #, _, {, }, &.
pandoctex = strrep(pandoctex,'$SYNTAX$',xxLatex(X.SYNTAX));
pandochtml = strrep(pandochtml,'$SYNTAX$',X.SYNTAX);

c = xxPreformat(c,REF);

ctex = xxPreformatTex(c);
char2file(ctex,tempFile);
[~,TEX] = system(pandoctex);

chtml = xxPreformatHtml(c);
char2file(chtml,tempFile);
[~,HTML] = system(pandochtml);

TEX = strfun.converteols(TEX);
HTML = strfun.converteols(HTML);

texfile = fullfile(irisroot(),'-help',[REF,'.tex']);
htmlfile = fullfile(irisroot(),'-help',[REF,'.html']);

char2file(TEX,texfile);
char2file(HTML,htmlfile);

delete(tempFile);

end


% Subfunctions...


%**************************************************************************


function C = xxPreformat(C,REF) %#ok<INUSD>

% Remove leading double space.
C = regexprep(C,'^  ','','lineanchors');

% Remove H1 line.
C = regexprep(C,'^[^\n]*(\n|$)','','once');

% Replace 3 spaces with 4 spaces.
C = regexprep(C,'^   (?![ \n])','    ','lineanchors');

% Replace 6 spaces with 8 spaces.
C = regexprep(C,'^      (?![ \n])','        ','lineanchors');

% Replace " - Returns" with " -- Returns".
C = regexprep(C,' - Returns',' -- Returns');

% Replace "] -" with "] -- ".
C = regexprep(C,'^(\*[^\n]+\]) - (?=\w:\\)','$1 -- ','lineanchors');

% Remove line with "CLASS_NAME methods:".
C = regexprep(C,'^[ ]*\w+ methods:[ ]*\n','','once');

end % xxPreformat()


%**************************************************************************


function C = xxPreformatTex(C)
% Replace '{\xxx}' with '{}
replace = @xxLatex; %#ok<NASGU>
C = regexprep(C,'''\{(.*?)\}''','''\{${replace($1)}\}''');
end % xxPreformatTex()


%**************************************************************************


function C = xxPreformatHtml(C)
% Replace [xxx](aaa/bbb) with [xxx](../aaa/bbb.html).
C = regexprep(C,'\]\(([^\)]+)\)','](../$1.html)');
end % xxpreformahtml()


%**************************************************************************


function C = xxLatex(C)
    C = strrep(C,'\','\textbackslash ');
    C = strrep(C,'%','\%');
    C = strrep(C,'{','\{');
    C = strrep(C,'}','\}');
    C = strrep(C,'_','\_');
    C = strrep(C,'#','\#');
    C = strrep(C,'$','\$');
    C = strrep(C,'&','\&');
    C = strrep(C,'^','\textasciicircum');
end % xxLatex()
