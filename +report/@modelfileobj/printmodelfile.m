function C = printmodelfile(This)
% printmodelfile  [Not a public function] LaTeXify and syntax highlight model file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

offset = irisget('highcharcode');

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

file = file2char(This.filename,'cellstrl',This.options.lines);

% Choose escape character.
escList = '`@?$#~&":|!^[]{}<>';
esc = xxChooseEscChar(file,escList);
if isempty(esc)
    utils.error('report', ...
        ['Cannot print the model file. ', ...
        'Make sure at least on of these characters completely disappears ', ...
        'from the model file: %s.'], ...
        escList);
end
verbEsc = ['\verb',esc];

nLine = length(file);
if isinf(This.options.lines)
    This.options.lines = 1 : nLine;
end
nDigit = ceil(log10(max(This.options.lines)));

C = [C,'\definecolor{mylabel}{rgb}{0.55,0,0.35}',br];
C = [C,'\definecolor{myparam}{rgb}{0.90,0,0}',br];
C = [C,'\definecolor{mykeyword}{rgb}{0,0,0.75}',br];
C = [C,'\definecolor{mycomment}{rgb}{0,0.50,0}',br];

file = strrep(file,char(10),'');
file = strrep(file,char(13),'');
for i = 1 : nLine
    c = doOneLine(file{i});
    C = [C,c,' \\',br]; %#ok<AGROW>
end

C = strrep(C,['\verb',esc,esc],'');

% Nested functions.

%**************************************************************************
    function C = doOneLine(C)
        
        keywordsFunc = @doKeywords; %#ok<NASGU>
        paramValFunc = @doParamVal; %#ok<NASGU>
        
        [C,lab] = xxProtectLabels(C,offset);
        
        lineComment = '';
        pos = strfind(C,'%');
        if ~isempty(pos)
            pos = pos(1);
            lineComment = C(pos:end);
            C = C(1:pos-1);
        end

        if This.options.syntax
            % Keywords.
            if ismatlab
                C = regexprep(C, ...
                    '!!|!\<\w+\>|=#|&\<\w+>|\$.*?\$', ...
                    '${keywordsFunc($0)}');
            else
                C = myregexprep(C, ...
                    '!!|!\<\w+\>|=#|&\<\w+>|\$.*?\$', ...
                    '${doKeywords($0)}');
            end
            % Line comments.
            if ~isempty(lineComment)
                lineComment = [ ...
                    esc, ...
                    '{\color{mycomment}', ...
                    verbEsc,lineComment,esc, ...
                    '}', ...
                    verbEsc];
            end
        end
        
        if isModel && This.options.paramvalues
            % Find words not preceeded by an !; whether they really are parameter names
            % or std errors is verified within doParamVal.
            if ismatlab
                C = regexprep(C, ...
                    '(?<!!)\<\w+\>', ...
                    '${paramValFunc($0)}');
            elseb
                C = myregexprep(C, ...
                    '(?<!!)\<\w+\>', ...
                    '${doParamVal($0)}');
            end
        end
        
        if This.options.linenumbers
            C = [ ...
                sprintf('%*g: ',nDigit,This.options.lines(i)), ...
                C];
        end
        C = xxLabelsBack(C,lab,offset,esc, ...
            This.options.syntax,This.options.latexalias);
        
        % Put labels back into comments; no syntax colouring or latexing aliases.
        lineComment = xxLabelsBack(lineComment,lab,offset,esc, ...
            false,false);

        C = [verbEsc,C,lineComment,esc];
        
        function C = doKeywords(C)
            if strcmp(C,'!!') || strcmp(C,'=#') ...
                    || strncmp(C,'&',1) || strncmp(C,'$',1)
                color = 'red';
            else
                color = 'mykeyword';
            end
            C = [ ...
                '{\color{',color,'}', ...
                verbEsc,C,esc, ...
                '}', ...
                ];
            C = [esc,C,verbEsc];
        end
        
        function C = doParamVal(C)
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
            C = [C,esc,value,verbEsc];
        end
        
    end % doSyntax().

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
function C = xxLabelsBack(C,Labels,Offset,Esc,IsSyntax,IsLatexAlias)

verbEsc = ['\verb',Esc];

for i = 1 : length(Labels)
    pos = strfind(C,char(Offset+i));
    if isempty(pos)
        continue
    end
    split = strfind(Labels{i},'!!');
    openQuote = Labels{i}(1);
    closeQuote = Labels{i}(end);
    if ~isempty(split)
        split = split(1);
        label = Labels{i}(2:split+1);
        alias = Labels{i}(split+2:end-1);
        if IsLatexAlias
            alias = [Esc,alias,verbEsc]; %#ok<AGROW>
        end
    else
        label = Labels{i}(2:end-1);
        alias = '';
    end
    
    if IsSyntax
        pre = [Esc,'{\color{mylabel}',verbEsc];
        post = [Esc,'}',verbEsc];
    else
        pre = '';
        post = '';
    end
    
    C = [ ...
        C(1:pos-1), ...
        pre, ...
        openQuote, ...
        label,alias, ...
        closeQuote, ...
        post, ...
        C(pos+1:end), ...
        ];
end

end % xxLabelsBack().

%**************************************************************************
function Esc = xxChooseEscChar(File,EscList)

File = [File{:}];
Esc = '';
for i = 1 : length(EscList)
    if isempty(strfind(File,EscList(i)))
        Esc = EscList(i);
        break
    end
end

end % xxChooseEscChar().
