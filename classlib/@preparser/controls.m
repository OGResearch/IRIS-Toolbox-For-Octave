function [C,Export] = controls(C,D,ErrorParsing,Labels,Export)
% controls  [Not a public function] Preparse control commands !if, !switch, !for, !export.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

try
    D; 
catch 
    D = struct();
end

try
    Labels;
catch
    Labels = {};
end

try
    Export;
catch
    Export = struct('filename',{},'content',{});
end

%--------------------------------------------------------------------------

Error = struct();
Error.code = '';
Error.exprsn = '';
Error.leftover = '';

% Cannot evaluate expression.
warn = {};

startControls = xxStartControls();
[pos,command] = regexp(C,startControls,'once','start','match');
while ~isempty(pos)
    len = length(command);
    head = C(1:pos-1);
    command(1) = '';
    
    commandCap = [upper(command(1)),lower(command(2:end))];
    [s,tail,isError] = feval(['xxParse',commandCap],C,pos+len);
    if isError
        Error.code = C(pos:end);
        break
    end
    
    [replace,Error.exprsn,thisWarn] = ...
        feval(['xxReplace',commandCap],s,D,Labels,ErrorParsing);
    
    if ~isempty(Error.exprsn)
        break
    end
    
    if ~isempty(thisWarn)
        warn = [warn,thisWarn]; %#ok<AGROW>
    end
    
    if strcmp(command,'export')
        Export = xxExport(s,Export,Labels);
    end
            
    C = [head,replace,tail];
    [pos,command] = regexp(C,startControls,'once','start','match');
end

if ~isempty(warn)
    warn = strtrim(warn);
    utils.warning('preparser', ...
        ['Cannot properly evaluate this ', ...
        'control command condition: ''%s''.'], ...
        warn{:});
end

pattern = [startControls,'|!do|!elseif|!else|!case|!otherwise|!end'];
pattern = ['(',pattern,')(?!\w)'];
pos = regexp(C,pattern,'once','start');
if ~isempty(pos)
    Error.leftover = C(pos:end);
end

doError();

% Nested functions.

%**************************************************************************
    function doError()
        if ~isempty(Error.code)
            utils.error('preparser', [ErrorParsing, ...
                'Something wrong with this control command(s) or commands nested inside: ''%s...''.'], ...
                xxFormatError(Error.code,Labels));
        end
        
        if ~isempty(Error.exprsn)
            utils.error('preparser', [ErrorParsing, ...
                'Cannot evaluate this control expression: ''%s...''.'], ...
                xxFormatError(Error.exprsn,Labels));
        end
        
        if ~isempty(Error.leftover)
            utils.error('preparser', [ErrorParsing, ...
                'This control command is miplaced or unfinished: ''%s...''.'], ...
                xxFormatError(Error.leftover,Labels));
        end
    end % doError().

end

%**************************************************************************
function C = xxStartControls()
    C = '!if|!for|!switch|!export';
end % xxStartControls().

%**************************************************************************
function [S,Tail,Error] = xxParseFor(C,Pos) %#ok<DEFNU>

S = struct();
S.ForBody = '';
S.DoBody = '';
Tail = '';

[S.ForBody,Pos,match] = xxFindSubControl(C,Pos,'!do');
Error = ~strcmp(match,'!do');
if Error
    return
end

[S.DoBody,Pos,match] = xxFindEnd(C,Pos);
Error = ~strcmp(match,'!end');
if Error
    return
end

Tail = C(Pos:end);

end % xxParserFor().

%**************************************************************************
function [S,Tail,Error] = xxParseIf(C,Pos) %#ok<DEFNU>

S = struct();
S.IfCond = '';
S.IfBody = '';
S.ElseifCond = {};
S.ElseifBody = {};
S.ElseBody = '';
Tail = '';
getcond = @(x) regexp(x,'^[^;\n]+','match','end','once');

[If,Pos,match] = xxFindSubControl(C,Pos,{'!elseif','!else'});
Error = ~any(strcmp(match,{'!elseif','!else','!end'}));
if Error
    return
end
[S.IfCond,finish] = getcond(If);
S.IfBody = If(finish+1:end);

while strcmp(match,'!elseif')
    [Elseif,Pos,match] = xxFindSubControl(C,Pos,{'!elseif','!else'});
    Error = ~any(strcmp(match,{'!elseif','!else','!end'}));
    if Error
        return
    end
    [S.ElseifCond{end+1},finish] = getcond(Elseif);
    S.ElseifBody{end+1} = Elseif(finish+1:end);
end

if strcmp(match,'!else')
    [S.ElseBody,Pos,match] = xxFindEnd(C,Pos);
    Error = ~strcmp(match,'!end');
    if Error
        return
    end
end

Tail = C(Pos:end);

end % xxParseIf().

%**************************************************************************
function [S,Tail,Error] = xxParseSwitch(C,Pos) %#ok<DEFNU>

S = struct();
S.SwitchExp = '';
S.CaseExp = {};
S.CaseBody = {};
S.OtherwiseBody = '';
Tail = '';
getcond = @(x) regexp(x,'^[^;\n]+','match','end','once');

[S.SwitchExp,Pos,match] = xxFindSubControl(C,Pos,{'!case','!otherwise'});
Error = ~any(strcmp(match,{'!case','!otherwise','!end'}));
if Error
    return
end

while strcmp(match,'!case')
    [Case,Pos,match] = xxFindSubControl(C,Pos,{'!case','!otherwise'});
    Error = ~any(strcmp(match,{'!case','!otherwise','!end'}));
    if Error
        return
    end
    [S.CaseExp{end+1},finish] = getcond(Case);
    S.CaseBody{end+1} = Case(finish+1:end);
end

if strcmp(match,'!otherwise')
    [S.OtherwiseBody,Pos,match] = xxFindEnd(C,Pos);
    Error = ~strcmp(match,'!end');
    if Error
        return
    end
end

Tail = C(Pos:end);

end % xxParseSwitch().

%**************************************************************************
function [S,Tail,Error] = xxParseExport(C,Pos) %#ok<DEFNU>

S = struct();
S.ExportName = '';
S.ExportBody = '';
Tail = '';

[export,Pos,match] = xxFindEnd(C,Pos);
Error = ~strcmp(match,'!end');
if Error
    return
end

name = regexp(export,'^\s*\([^\n\)]*\)','once','match');
if isempty(name)
    Error = ['!export ',export];
    return
end
S.ExportName = strtrim(name(2:end-1));
S.ExportBody = regexprep(export,'^\s*\([^\n\)]+\)','','once');
S.ExportBody = strfun.removeltel(S.ExportBody);

Tail = C(Pos:end);

end % xxParseExport().

%**************************************************************************
function [Replace,Error,Warn] = xxReplaceFor(S,D,Labels,ErrorParsing) %#ok<DEFNU>

Replace = '';
Error = '';
Warn = {};

forBody = S.ForBody;
doBody = S.DoBody;

forBody = strtrim(forBody);
control = regexp(forBody,'^\?[^\s=!]*','once','match');
if isempty(control)
    control = '?';
end

% Put labels back in the !for body.
forBody = xxLabelsBack(forBody,Labels);

% List of parameters supplied through `'assign='` as `'\<a|b|c\>'`
plist = fieldnames(D);
if ~isempty(plist)
    plist = sprintf('%s|',plist{:});
    plist(end) = '';
    plist = ['\<(',plist,')\>'];
end

% Expand [ ... ].
replaceFunc = @doexpandsqb; %#ok<NASGU>
forBody = regexprep(forBody,'\[[^\]]*\]','${replaceFunc($0)}');

if ~isempty(Error)
    return
end

% Remove `'name='` from `forbody` to get the RHS.
forBody = regexprep(forBody,[control,'\s*=\s*'],'');

% Itemize the RHS of the `forbody`.
if ~isempty(strfind(forBody,'!'))
    % We allow for !if commands inside !for list, and hence need to pre-parse
    % the list first.
    forBody = preparser.controls(forBody,D,ErrorParsing,Labels);
end
list = regexp(forBody,'[^\s,;]+','match');

    function C1 = doexpandsqb(C)
        % doexpandsqb  Expand Matlab expressions in square brackets.
        C1 = '';
        try
            if ~isempty(plist)
                % Replace references to fieldnames of D with D.fieldname.
                C = regexprep(C,plist,'D.$1');
            end
            % Create an anonymous function handle and evaluate it on D.
            f = str2func(['@(D) ',C]);
            x = f(D);
            % The results may only be numeric arrays, logical arrays, character
            % strings, or cell arrays of these. Any other results will be discarded.
            if ~iscell(x)
                x = {x};
            end
            nx = length(x);
            for ii = 1 : nx
                if isnumeric(x{ii}) || islogical(x{ii})
                    C1 = [C1,sprintf('%g,',x{ii})]; %#ok<AGROW>
                elseif ischar(x{ii})
                    C1 = [C1,x{ii},',']; %#ok<AGROW>
                end
            end
        catch %#ok<CTCH>
            Error = ['!for ',forBody];
        end        
    end

lowerList = lower(list);
upperList = upper(list);
Replace = '';
br = sprintf('\n');
nList = length(list);

for i = 1 : nList
    template = doBody;
    % These are the preferred options.
    if length(control) > 1
        template = strrep(template, ...
            [control(1),'.',control(2:end)], ...
            lowerList{i});
        template = strrep(template, ...
            [control(1),':',control(2:end)], ...
            upperList{i});
    end
    % The following ones are for bkw compatibility only.
    template = strrep(template,['!lower',control],lowerList{i});
    template = strrep(template,['!upper',control],upperList{i});
    template = strrep(template,['<lower(',control,')>'],lowerList{i});
    template = strrep(template,['<upper(',control,')>'],upperList{i});
    template = strrep(template,['lower(',control,')'],lowerList{i});
    template = strrep(template,['upper(',control,')'],upperList{i});
    template = strrep(template,['<-',control,'>'],lowerList{i});
    template = strrep(template,['<+',control,'>'],upperList{i});
    template = strrep(template,['<',control,'>'],list{i});
    % Finally, this is the plain control variable substitution.
    template = strrep(template,control,list{i});
    % Remove leading and trailing empty lines.
    template = strfun.removeltel(template);
    Replace = [Replace,br,template]; %#ok
end

end % xxReplaceFor().

%**************************************************************************
function [Replace,Error,Warn] = xxReplaceIf(S,D,Labels,~) %#ok<DEFNU>

Replace = ''; %#ok<NASGU>
Error = '';
Warn = {};
br = sprintf('\n');

[value,valid] = xxEval(S.IfCond,D,Labels);
if ~valid
    Warn{end+1} = S.IfCond;
end
if value
    Replace = S.IfBody;
    Replace = [br,Replace];
    Replace = strfun.removeltel(Replace);
    return
end

for i = 1 : length(S.ElseifCond)
    [value,valid] = xxEval(S.ElseifCond{i},D,Labels);
    if ~valid
        Warn{end+1} = S.ElseifCond{i}; %#ok<AGROW>
    end
    if value
        Replace = S.ElseifBody{i};
        Replace = [br,Replace];%#ok<AGROW>
        Replace = strfun.removeltel(Replace);
        return
    end
end

Replace = S.ElseBody;
Replace = [br,Replace];
Replace = strfun.removeltel(Replace);
    
end % xxReplaceIf().

%**************************************************************************
function [Replace,Error,Warn] = xxReplaceSwitch(S,D,Labels,~) %#ok<DEFNU>

Replace = ''; %#ok<NASGU>
Error = '';
Warn = {};
br = sprintf('\n');

[switchexp,switchvalid] = xxEval(S.SwitchExp,D,Labels);
if ~switchvalid
    Warn{end+1} = S.SwitchExp;
end
if ~switchvalid
    Replace = S.OtherwiseBody;
    Replace = [br,Replace];
    Replace = strfun.removeltel(Replace);
    return
end

for i = 1 : length(S.CaseExp)
    [caseexp,valid] = xxEval(S.CaseExp{i},D,Labels);
    if valid && isequal(switchexp,caseexp)
        Replace = S.CaseBody{i};
        Replace = [br,Replace]; %#ok<AGROW>
        Replace = strfun.removeltel(Replace);
        return
    end
end

Replace = S.OtherwiseBody;
Replace = [br,Replace];
Replace = strfun.removeltel(Replace);

end % xxReplaceSwitch().

%**************************************************************************
function [Replace,Error,Warn] = xxReplaceExport(S,D,Labels,~) %#ok<INUSD,DEFNU>

Replace = '';
Error = '';
Warn = {};

end % xxReplaceExport().

%**************************************************************************
function Export = xxExport(S,Export,Labels)

if ~isfield(S,'ExportName') || isempty(S.ExportName) ...
        || ~isfield(S,'ExportBody')
    return
end

S.ExportBody = xxLabelsBack(S.ExportBody,Labels);

Export(end+1).filename = S.ExportName;
Export(end).content = S.ExportBody;

end % xxReplaceExport().

%**************************************************************************
function [Body,Pos,Match] = xxFindSubControl(C,Pos,SubControl)

startPos = Pos;
Body = '';
Match = '';
startControls = xxStartControls();
stop = false;
level = 0;
if ischar(SubControl)
    s = ['|',SubControl];
elseif iscellstr(SubControl)
    s = sprintf('|%s',SubControl{:});
end     

pattern = [startControls,'|!end',s];
pattern = ['(',pattern,')(?!\w)'];
while ~stop
    [start,Match] = ...
        regexp(C(Pos:end),pattern,'start','match','once');
    Pos = Pos + start - 1;
    switch Match
        case SubControl
            stop = level == 0;
            Body = C(startPos:Pos-1);
        case '!end'
            level = level - 1;
            if level < 0
                stop = true;
                Body = C(startPos:Pos-1);
            end
        otherwise
            if ~isempty(start)
                level = level + 1;  
            else
                stop = true;
            end
    end
    Pos = Pos + length(Match);
end

end % xxFindSubControl().

%**************************************************************************
function [Body,Pos,Match] = xxFindEnd(C,Pos)

startPos = Pos;
Body = '';
Match = '';
startControls = xxStartControls();
stop = false;
level = 0;

while ~stop
    [start,Match] = ...
        regexp(C(Pos:end),[startControls,'|!end'], ...
        'start','match','once');
    Pos = Pos + start - 1;
    switch Match
        case '!end'
            if level == 0
                stop = true;
                Body = C(startPos:Pos-1);
            else
                level = level - 1;
            end
        otherwise
            if ~isempty(start)
                level = level + 1;  
            else
                stop = true;
            end
    end
    Pos = Pos + length(Match);
end

end % xxFindEnd().

%**************************************************************************
function [Value,Valid] = xxEval(Exp,D,Labels)
% doevalexpression  Evaluate !if and !switch expressions within database.

Exp = strtrim(Exp);
Exp = strrep(Exp,'!','');

% Add `D.` to all of its fields.
if isstruct(D)
    list = fieldnames(D)';
else
    list = {};
end
for i = 1 : length(list)
    Exp = regexprep(Exp,['(?<![\.!])\<',list{i},'\>'],['?.',list{i}]);
end
Exp = strrep(Exp,'?.','D.');

% Put labels back because some of them can be strings in !if or !switch
% expressions.
if ~isempty(Labels)
    Exp = xxLabelsBack(Exp,Labels);
end

% Evaluate the expression.
try
    Value = eval(Exp);
    Valid = true;
catch %#ok<CTCH>
    Value = false;
    Valid = false;
end

end % xxEval().

%**************************************************************************
function C = xxLabelsBack(C,Labels)
% xxLabelsBack  Substitute labels back for #(NN) in a string.

if isempty(Labels)
    return
end

    function s = replace(x)
        s = '''''';
        x = sscanf(x,'#(%g)');
        if ~isempty(x) && ~isnan(x)
            s = ['''',Labels{x},''''];
        end
    end

% End of nested function replace().
replaceFunc = @replace; %#ok<NASGU>
C = regexprep(C,'(#\(\d+\))','${replaceFunc($1)}');

end % xxLabelsBack().

%**************************************************************************
function C = xxFormatError(C,Labels)

if iscell(C)
    for i = 1 : length(C)
        C{i} = xxFormatError(C{i},Labels);
    end
    return
end
C = xxLabelsBack(C,Labels);
C = regexprep(C,'\s+',' ');
C = strtrim(C);
C = strfun.maxdisp(C,40);

end % xxformatforerror().