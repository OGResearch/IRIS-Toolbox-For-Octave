function [C,Labels,Export] = controls(C,D,ErrParsing,Labels,Export)
% controls  [Not a public function] Preparse control commands !if, !switch, !for, !export.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

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
warnParsing = strrep(ErrParsing,'Error','Warning');

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
    
    [replace,Labels,Error.exprsn,thisWarn] = ...
        feval(['xxReplace',commandCap],s,D,Labels,ErrParsing);
    
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
    warn = restore(warn,Labels);
    utils.warning('preparser:controls',[warnParsing, ...
        'Cannot properly evaluate this ', ...
        'control command condition: ''%s''.'], ...
        warn{:});
end

pattern = [startControls,'|!do|!elseif|!else|!case|!otherwise|!end'];
pattern = ['(',pattern,')(?!\w)'];
pos = regexp(C,pattern,'once','start');
if ~isempty(pos)
    Error.leftover = C(pos:end);
end

doErrors();


% Nested functions...


%**************************************************************************


    function doErrors()
        if ~isempty(Error.code)
            utils.error('preparser:controls', [ErrParsing, ...
                'Something wrong with this control command(s) or commands nested inside: ''%s...''.'], ...
                xxFormatError(Error.code,Labels));
        end
        
        if ~isempty(Error.exprsn)
            utils.error('preparser:controls', [ErrParsing, ...
                'Cannot evaluate this control expression: ''%s...''.'], ...
                xxFormatError(Error.exprsn,Labels));
        end
        
        if ~isempty(Error.leftover)
            utils.error('preparser:controls', [ErrParsing, ...
                'This control command is miplaced or unfinished: ''%s...''.'], ...
                xxFormatError(Error.leftover,Labels));
        end
    end % doError()

end


% Subfunctions...


%**************************************************************************


function C = xxStartControls()
    C = '!if|!for|!switch|!export';
end % xxStartControls()


%**************************************************************************


function [S,Tail,Err] = xxParseFor(C,Pos) %#ok<DEFNU>

S = struct();
S.ForBody = '';
S.DoBody = '';
Tail = '';

[S.ForBody,Pos,match] = xxFindSubControl(C,Pos,'!do');
Err = ~strcmp(match,'!do');
if Err
    return
end

[S.DoBody,Pos,match] = xxFindEnd(C,Pos);
Err = ~strcmp(match,'!end');
if Err
    return
end

Tail = C(Pos:end);

end % xxParserFor().


%**************************************************************************


function [S,Tail,Err] = xxParseIf(C,Pos) %#ok<DEFNU>

S = struct();
S.IfCond = '';
S.IfBody = '';
S.ElseifCond = {};
S.ElseifBody = {};
S.ElseBody = '';
Tail = '';
getcond = @(x) regexp(x,'^[^;\n]+','match','end','once');

[If,Pos,match] = xxFindSubControl(C,Pos,{'!elseif','!else'});
Err = ~any(strcmp(match,{'!elseif','!else','!end'}));
if Err
    return
end
[S.IfCond,finish] = getcond(If);
S.IfBody = If(finish+1:end);

while strcmp(match,'!elseif')
    [Elseif,Pos,match] = xxFindSubControl(C,Pos,{'!elseif','!else'});
    Err = ~any(strcmp(match,{'!elseif','!else','!end'}));
    if Err
        return
    end
    [S.ElseifCond{end+1},finish] = getcond(Elseif);
    S.ElseifBody{end+1} = Elseif(finish+1:end);
end

if strcmp(match,'!else')
    [S.ElseBody,Pos,match] = xxFindEnd(C,Pos);
    Err = ~strcmp(match,'!end');
    if Err
        return
    end
end

Tail = C(Pos:end);

end % xxParseIf()


%**************************************************************************


function [S,Tail,Err] = xxParseSwitch(C,Pos) %#ok<DEFNU>

S = struct();
S.SwitchExp = '';
S.CaseExp = {};
S.CaseBody = {};
S.OtherwiseBody = '';
Tail = '';
getcond = @(x) regexp(x,'^[^;\n]+','match','end','once');

[S.SwitchExp,Pos,match] = xxFindSubControl(C,Pos,{'!case','!otherwise'});
Err = ~any(strcmp(match,{'!case','!otherwise','!end'}));
if Err
    return
end

while strcmp(match,'!case')
    [Case,Pos,match] = xxFindSubControl(C,Pos,{'!case','!otherwise'});
    Err = ~any(strcmp(match,{'!case','!otherwise','!end'}));
    if Err
        return
    end
    [S.CaseExp{end+1},finish] = getcond(Case);
    S.CaseBody{end+1} = Case(finish+1:end);
end

if strcmp(match,'!otherwise')
    [S.OtherwiseBody,Pos,match] = xxFindEnd(C,Pos);
    Err = ~strcmp(match,'!end');
    if Err
        return
    end
end

Tail = C(Pos:end);

end % xxParseSwitch()


%**************************************************************************


function [S,Tail,Err] = xxParseExport(C,Pos) %#ok<DEFNU>

S = struct();
S.ExportName = '';
S.ExportBody = '';
Tail = '';

[export,Pos,match] = xxFindEnd(C,Pos);
Err = ~strcmp(match,'!end');
if Err
    return
end

name = regexp(export,'^\s*\([^\n\)]*\)','once','match');
if isempty(name)
    Err = ['!export ',export];
    return
end
S.ExportName = strtrim(name(2:end-1));
S.ExportBody = regexprep(export,'^\s*\([^\n\)]+\)','','once');
S.ExportBody = strfun.removeltel(S.ExportBody);

Tail = C(Pos:end);

end % xxParseExport()


%**************************************************************************


function [Replace,Labels,Err,Warn] ...
    = xxReplaceFor(S,D,Labels,ErrParsing) %#ok<DEFNU>

Replace = '';
Err = '';
Warn = {};
warnParsing = strrep(ErrParsing,'Error','Warning');
    
forBody = S.ForBody;
doBody = S.DoBody;

if ~isempty(strfind(forBody,'!'))
    % We allow for `!if` commands inside the `!for` body, and hence need to
    % pre-parse the body first.
    forBody = preparser.controls(forBody,D,ErrParsing,Labels);
end

% Read the name of the control variable.
forBody = strtrim(forBody);
control = regexp(forBody,'^\?[^\s=!]*','once','match');
if isempty(control)
    control = '?';
end

% Put labels back in the `!for` body.
forBody = restore(forBody,Labels);

% List of parameters supplied through `'assign='` as `'\<a|b|c\>'`
plist = fieldnames(D);
if ~isempty(plist)
    plist = sprintf('%s|',plist{:});
    plist(end) = '';
    plist = ['\<(',plist,')\>'];
end

% Expand `$[ ... ]$` and `[...]` (the latter for bkw compatibility) in the
% `!for` body.

% TODO: Use pseudosubstitutions to evaluate $[...]$ in the body of !for
% loops.

obsolete = {};
ptn = '(\$?)(\[[^\]]*\])\1';
if true % ##### MOSW
    replaceFunc = @doExpandSqb; %#ok<NASGU>
    forBody = regexprep(forBody,ptn,'${replaceFunc($1,$2)}');
else
    forBody = mosw.dregexprep(forBody,ptn,@doExpandSqb,[1,2]); %#ok<UNRCH>
end
if ~isempty(obsolete)
    % ##### May 2014 OBSOLETE and scheduled for removal.
    utils.warning('obsolete', [warnParsing, ...
        'This is obsolete syntax, and will be removed from a future ', ...
        'version of IRIS. Use pseudosubstitution syntax $[...]$ instead: ', ...
        '''%s''.'], ...
        obsolete{:});
end

if ~isempty(Err)
    return
end

% Remove `'name='` from `forbody` to get the RHS.
forBody = regexprep(forBody,[control,'\s*=\s*'],'');

% Itemize the RHS of the `!for` body.
list = regexp(forBody,'[^\s,;]+','match');

    function C = doExpandSqb(C1,C2)
        % doexpandsqb  Expand Matlab expressions in square brackets.
        C = '';
        try
            if ~isempty(plist)
                % Replace references to fieldnames of `'D'` with `'D.fieldname'`.
                C2 = regexprep(C2,plist,'D.$1');
            end
            % Create an anonymous function handle and evaluate it on D.
            f = str2func(['@(D) ',C2]);
            x = f(D);
            % The results may only be numeric arrays, logical arrays, character
            % strings, or cell arrays of these. Any other results will be discarded.
            if ~iscell(x)
                x = {x};
            end
            nx = length(x);
            for ii = 1 : nx
                if isnumeric(x{ii}) || islogical(x{ii})
                    C = [C,sprintf('%g,',x{ii})]; %#ok<AGROW>
                elseif ischar(x{ii})
                    C = [C,x{ii},',']; %#ok<AGROW>
                end
            end
        catch %#ok<CTCH>
            Err = ['!for ',forBody];
        end
        if isempty(C1)
            obsolete{end+1} = C2;
        end
    end

lowerList = lower(list);
upperList = upper(list);
Replace = '';
br = sprintf('\n');
nList = length(list);

isObsolete = false;
for i = 1 : nList
    C = doBody;
    
    % The following ones are for bkw compatibility only; throw a warning, and
    % remove from IRIS in the future.
    C0 = C;
    C = strrep(C,['!lower',control],lowerList{i});
    C = strrep(C,['!upper',control],upperList{i});
    C = strrep(C,['<lower(',control,')>'],lowerList{i});
    C = strrep(C,['<upper(',control,')>'],upperList{i});
    C = strrep(C,['lower(',control,')'],lowerList{i});
    C = strrep(C,['upper(',control,')'],upperList{i});
    C = strrep(C,['<-',control,'>'],lowerList{i});
    C = strrep(C,['<+',control,'>'],upperList{i});
    C = strrep(C,['<',control,'>'],list{i});
    isObsolete = isObsolete || length(C) ~= length(C0) || ~all(C == C0);
    
    % Handle standard syntax here.
    C = doSubsForControl(C,control,list{i});
    
    % Substitute for the control variable in labels.
    if ~isempty(Labels)
        ptn = regexppattern(Labels);
        % List of charcodes that actually occur in the `for` body.
        occur = regexp(C,ptn,'match');
        for j = 1 : length(occur)
            jCode = occur{j};
            % Position of the charcode `k` in the storage.
            pos = position(Labels,jCode);
            % Copy the `pos`-th entry to the end of storage.
            [Labels,newPos,newCode] = copytoend(Labels,pos);
            % Substitute inside the comment string.
            Labels.Store{newPos} ...
                = doSubsForControl(Labels.Store{newPos},control,list{i});
            C = strrep(C,jCode,newCode);
        end
    end
    
    C = strfun.removeltel(C);
    Replace = [Replace,br,C]; %#ok
end

if isObsolete
    doBody = restore(doBody,Labels);
    utils.warning('obsolete',[warnParsing, ...
        'The syntax for lower/upper case of a !for control variable ', ...
        'in the following piece of code is obsolete, and will be removed ', ...
        'from IRIS in the future: ''%s''.'], ...
        doBody);
end

    function C = doSubsForControl(C,Control,Subs)
        if length(Control) > 1
            lowerSubs = lower(Subs);
            upperSubs = upper(Subs);
            % Substitute lower(...) for for ?.name.
            C = strrep(C,[Control(1),'.',Control(2:end)],lowerSubs);
            % Substitute upper(...) for for ?:name.
            C = strrep(C,[Control(1),':',Control(2:end)],upperSubs);
        end
        % Substitute for ?name.
        C = strrep(C,Control,Subs);
    end

end % xxReplaceFor()


%**************************************************************************


function [Replace,Labels,Err,Warn] = xxReplaceIf(S,D,Labels,~) %#ok<DEFNU>

Replace = ''; %#ok<NASGU>
Err = '';
Warn = {};
br = sprintf('\n');

[value,valid] = preparser.eval(S.IfCond,D,Labels);
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
    [value,valid] = preparser.eval(S.ElseifCond{i},D,Labels);
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
    
end % xxReplaceIf()


%**************************************************************************


function [Replace,Labels,Err,Warn] = xxReplaceSwitch(S,D,Labels,~) %#ok<DEFNU>

Replace = ''; %#ok<NASGU>
Err = '';
Warn = {};
br = sprintf('\n');

[switchexp,switchvalid] = preparser.eval(S.SwitchExp,D,Labels);
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
    [caseexp,valid] = preparser.eval(S.CaseExp{i},D,Labels);
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

end % xxReplaceSwitch()


%**************************************************************************


function [Replace,Labels,Err,Warn] = xxReplaceExport(~,~,Labels,~) %#ok<DEFNU>
Replace = '';
Err = '';
Warn = {};
end % xxReplaceExport()


%**************************************************************************


function Export = xxExport(S,Export,Labels)

if ~isfield(S,'ExportName') || isempty(S.ExportName) ...
        || ~isfield(S,'ExportBody')
    return
end

S.ExportBody = restore(S.ExportBody,Labels);

Export(end+1).filename = S.ExportName;
Export(end).content = S.ExportBody;

end % xxExport()


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

end % xxFindSubControl()


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

end % xxFindEnd()


%**************************************************************************


function C = xxFormatError(C,Labels)

if iscell(C)
    for i = 1 : length(C)
        C{i} = xxFormatError(C{i},Labels);
    end
    return
end
C = restore(C,Labels);
C = regexprep(C,'\s+',' ');
C = strtrim(C);
C = strfun.maxdisp(C,40);

end % xxformatforerror()