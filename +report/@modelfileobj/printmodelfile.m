function C = printmodelfile(This)
% printmodelfile  [Not a public function] LaTeXify and syntax highlight model file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

offset = irisget('highcharcode');

% TODO: Check for '@' in the model file; if found replace the \verb
% delimiter with something else or remove all @s from the model file.
% TODO: Handle comment blocks %{...%} properly.
C = '';
if isempty(This.filename)
    return
end
isModel = ~isempty(This.modelobj) && isa(This.modelobj,'modelobj');
if isModel
    pList = get(This.modelobj,'pList');
    eList = get(This.modelobj,'eList');
end
br = sprintf('\n');

line = file2char(This.filename,'cellstrl',This.options.lines);
nLine = length(line);
if isinf(This.options.lines)
    This.options.lines = 1 : nLine;
end
nDigit = ceil(log10(max(This.options.lines)));

C = [C,'\definecolor{mylabel}{rgb}{0.55,0,0.35}',br];
C = [C,'\definecolor{myparam}{rgb}{0.90,0,0}',br];
C = [C,'\definecolor{mykeyword}{rgb}{0,0,0.75}',br];
C = [C,'\definecolor{mycomment}{rgb}{0,0.50,0}',br];

line = strrep(line,char(10),'');
line = strrep(line,char(13),'');
for i = 1 : nLine
    % Split the line if there is a line comment.
    tok = regexp(line{i},'([^%]*)(%.*)?','tokens','once');
    if ~isempty(tok)
        x = tok{1};
        y = tok{2};
    else
        x = '';
        y = '';
    end
    % Protect labels.
    x = doSyntax(x);
    y = doComments(y);
    C = [C,x,y,' \\',br]; %#ok<AGROW>
end

% Nested functions.

%**************************************************************************
    function C = doSyntax(C)
        
        keywordsFunc = @doKeywords; %#ok<NASGU>
        %labelsFunc = @doLabels; %#ok<NASGU>
        paramValuesFunc = @doParamValues; %#ok<NASGU>
        
        [C,lab] = xxProtectLabels(C,offset);
        
        if This.options.syntax
            C = regexprep(C, ...
                '!!|!\<\w+\>|=#|&\<\w+>|\$.*?\$', ...
                '${keywordsFunc($0)}');
        end
        if isModel && This.options.paramvalues
            % Find words not preceeded by an !; whether they really are parameter names
            % or std errors is verified within paramvalues.
            C = regexprep(C, ...
                '(?<!!)\<\w+\>', ...
                '${paramValuesFunc($0)}');
        end
        if This.options.linenumbers
            C = [ ...
                sprintf('%*g: ',nDigit,This.options.lines(i)), ...
                C];
        end
        
        C = xxLabelsBack(C,lab,offset,This.options);
        
        C = ['\verb@',C,'@'];
        
        function C = doKeywords(C)
            if strcmp(C,'!!') || strcmp(C,'=#') ...
                    || strncmp(C,'&',1) || strncmp(C,'$',1)
                color = 'red';
            else
                color = 'mykeyword';
            end
            C = latex.stringsubs(C);
            C = ['\textcolor{',color,'}{\texttt{',C,'}}'];
            C = ['@',C,'\verb@'];
        end
        
        function C = doParamValues(C)
            if any(strcmp(C,eList))
                value = This.modelobj.(['std_',C]);
                prefix = '\sigma\!=\!';
            elseif any(strcmp(C,pList))
                value = This.modelobj.(C);
                prefix = '';
            else
                return
            end
            value = sprintf('%g',value(1));
            value = strrep(value,'Inf','\infty');
            value = strrep(value,'NaN','\mathrm{NaN}');
            value = ['{\color{myparam}$\left<{', ...
                prefix,value,'}\right>$}'];
            C = [C,'@',value,'\verb@'];
        end
        
    end % doSyntax().

%**************************************************************************
    function C1 = doComments(C)
        C1 = '{';
        if This.options.syntax
            C1 = [C1,'\color{mycomment}'];
        end
        C1 = [C1,'\verb@',C,'@}'];
    end % doComments().

end

% Subfunctions.

%**************************************************************************
function [C,Labels] = xxProtectLabels(C,Offset)

Labels = {};
while true
    [tok,start,finish] = regexp(C,'([''"])([^\n]*?)\1', ...
        'once','tokens','start','end');
    if isempty(tok)
        break
    end
    Labels{end+1} = C(start:finish); %#ok<AGROW>
    C = [C(1:start-1),char(Offset+length(Labels)),C(finish+1:end)];
end

end % xxProtectLabels().

%**************************************************************************
function C = xxLabelsBack(C,Labels,Offset,Opt)

% Typeset alias interpreting it as LaTeX code.
latexAlias = Opt.latexalias;

% Syntax highlighting.
isSyntax = Opt.syntax;

for i = 1 : length(Labels)
    pos = strfind(C,char(Offset+i));
    split = strfind(Labels{i},'!!');
    if ~isempty(split)
        split = split(1);
        quotes = Labels{i}(1);
        label = latex.stringsubs(Labels{i}(2:split+1));
        alias = Labels{i}(split+2:end-1);
        if ~latexAlias
            alias = latex.stringsubs(alias);
        end
    else
        quotes = Labels{i}(1);
        label = latex.stringsubs(Labels{i}(2:end-1));
        alias = '';
    end
    
    % Syntax highlighting.
    if isSyntax
        preSyntax = '@\textcolor{mylabel}{\texttt{';
        postSyntax = '}}\verb@';
    else
        preSyntax = '';
        postSyntax = '';
    end
    
    C = [C(1:pos-1), ...
        preSyntax, ...
        quotes,label,alias,quotes, ...
        postSyntax, ...
        C(pos+1:end)];
end

end % xxLabelsBack().

