classdef preparser < userdataobj
% preparser  [Not a public class] IRIS pre-parser for model, sstate, and quick-report files.
%
% Backend IRIS class.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

    properties
        assign = struct();
        fname = '';
        code = '';
        labels = fragileobj();
        Export = {};
        subs = struct();
    end
        
    methods
        
        function This = preparser(varargin)
            % preparser  [Not a public function] General IRIS code preparser.
            %
            
            % p = preparser(inputFile,Opt)
            % p = preparser(inputFile,...)
            
            if nargin == 0
                return
            end

            if isa(varargin{1},'preparser')
                This = varargin{1};
                return
            end
            inputFiles = varargin{1};
            varargin(1) = [];
            if ischar(inputFiles)
                inputFiles = {inputFiles};
            end
            This.fname = inputFiles{1};
            for i = 2 : length(inputFiles)
                This.fname = [This.fname,' & ',inputFiles{2}];
            end
            % Parse options.
            if ~isempty(varargin) && isstruct(varargin{1})
                opt = varargin{1};
                varargin(1) = [];
            else
                [opt,varargin] = ...
                    passvalopt('preparser.preparser',varargin{:});
            end
            % Add remaining input arguments to the assign struct.
            if ~isempty(varargin) && iscellstr(varargin(1:2:end))
                for i = 1 : 2 : length(varargin)
                    opt.assign.(varargin{i}) = varargin{i+1};
                end
            end
            This.assign = opt.assign;
            % Read the code files and resolve preparser commands.
            [This.code,This.labels,This.Export,This.subs,This.Comment] = ...
                preparser.readcode(inputFiles, ...
                opt.assign,This.labels,{},'',opt);
            % Create a clone of the preparsed code.
            if ~isempty(opt.clone)
                This.code = preparser.myclone(This.code,opt.clone);
            end
            % Save the pre-parsed file if requested by the user.
            if ~isempty(opt.saveas)
                saveas(This,opt.saveas);
            end
        end
        
        function disp(This)
            fprintf('\tpreparser object <a href="matlab:edit %s">%s</a>\n', ...
                This.fname,This.fname);
            %disp@userdataobj(This); % commented out while this syntax is not yet implemented in Octave
            disp(This);
            disp(' ');
        end
        %{
        varargout = saveas(varargin)
        %}
    end
    %{
    methods (Hidden)
        % TODO: Create reportingobj and make the parser its method.
        varargout = reporting(varargin)
    end
    %}
    methods (Static,Hidden)
    %{
        varargout = mychkclonestring(varargin)
        varargout = myclone(varargin)
        varargout = alt2str(varargin)
        varargout = export(varargin)
        varargout = grabcommentblk(varargin)
        varargout = labeledexpr(varargin)
        varargout = lincomb2vec(varargin)
        varargout = controls(varargin)
        varargout = pseudofunc(varargin)
        varargout = readcode(varargin)
        varargout = substitute(varargin)
    %}
        function [Code,Labels,Export,Subs,Comment] = readcode(FileList,Params,Labels,Export,ParentFile,Opt)
        % readcode  [Not a public function] Preparser master file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if isempty(Params)
    Params = struct([]);
end

if isempty(Export)
    Export = struct('filename',{},'content',{});
end

if isempty(ParentFile)
    ParentFile = '';
end

if isempty(Opt.removecomments)
    Opt.removecomments = {};
end

%--------------------------------------------------------------------------

Code = '';
Comment = '';
Subs = struct();

if ischar(FileList)
    FileList = {FileList};
end

fileStr = '';
nFileList = length(FileList);
for i = 1 : nFileList
    Code = [Code,sprintf('\n'),file2char(FileList{i})]; %#ok<AGROW>
    fileStr = [fileStr,FileList{i}]; %#ok<AGROW>
    if i < nFileList
        fileStr = [fileStr,' & ']; %#ok<AGROW>
    end
end

fileStr = sprintf('<a href="matlab:edit %s">%s</a>',fileStr,fileStr);
if ~isempty(ParentFile)
    fileStr = [ParentFile,' > ',fileStr];
end
errorParsing = ['Error preparsing file(s) ',fileStr,'. '];

% Convert end of lines.
Code = strfun.converteols(Code);

% Check if there is an initial %% comment line that will be used as comment
% in model objects.
tokens = regexp(Code,'^\s*%%([^\n]+)','tokens','once');
if ~isempty(tokens)
    Comment = strtrim(tokens{1});
end

% Characters beyond char(highcharcode) not allowed except comments.
% Default is 1999.
charCap = irisget('highcharcode');
if (ismatlab && any(Code > char(charCap))) || (~ismatlab && any(char2double(Code)>charCap))
    utils.error('preparser',[errorParsing, ...
        'The file contains characters beyond char(%g).'],charCap);
end

% Read quoted strings 'xxx' and "xxx" and replace them with charcodes.
% The quoted strings must not stretch across mutliple lines.
if isnan(Labels)
    % Initialise the fragileobj object.
    Labels = fragileobj(Code);
end
[Code,Labels] = protectquotes(Code,Labels);

% Remove standard line and block comments.
Code = strfun.removecomments(Code,Opt.removecomments{:});

% Remove triple exclamation point !!!.
% This mark is meant to be used to highlight some bits of the code.
Code = strrep(Code,'!!!','');

% Replace @keywords with !keywords. This is for backward compatibility
% only.
Code = preparser.xxPrefix(Code);

% Discard everything after !stop.
pos = strfind(Code,'!stop');
if ~isempty(pos)
    Code = Code(1:pos(1)-1);
end

% Add a white space at the end.
Code = [Code,sprintf('\n')];

% Execute control commands
%--------------------------
% Evaluate and expand the following control commands:
% * !if .. !else .. !elseif .. !end
% * !for .. !do .. !end
% * !switch .. !case ... !otherwise .. !end
% * !export .. !end
[Code,Labels,Export] ...
    = preparser.controls(Code,Params,errorParsing,Labels,Export);

% Import external files
%-----------------------

[Code,Labels,Export] = preparser.xxImport(Code,Params,Labels,Export,fileStr,Opt);

% Expand pseudofunctions
%------------------------

[Code,invalid] = preparser.pseudofunc(Code);
if ~isempty(invalid)
    invalid = xxFormatError(invalid,Labels);
    utils.error('preparser',[errorParsing, ...
        'Invalid pseudofunction: ''%s''.'], ...
        invalid{:});
end

% Expand substitutions
%----------------------

% Expand substitutions in the top file after all imports have been done.
if isempty(ParentFile)
    [Code,Subs,leftover,multiple,undef] ...
        = preparser.substitute(Code);
    if ~isempty(leftover)
        leftover = preparser.xxFormatError(leftover,Labels);
        utils.error('preparser',[errorParsing, ...
            'There is a leftover code in a substitutions block: ''%s''.'], ...
            leftover{:});
    end
    if ~isempty(multiple)
        multiple = preparser.xxFormatError(multiple,Labels);
        utils.error('preparser',[errorParsing, ...
            'This substitution name is defined more than once: ''%s''.'], ...
            multiple{:});
    end
    if ~isempty(undef)
        utils.error('preparser',[errorParsing, ...
            'This is an unresolved or undefined substitution: ''%s''.'], ...
            undef{:});
    end
end

% Remove leading and trailing empty lines.
Code = strfun.removeltel(Code);

end

% Subfunctions.

%**************************************************************************
function Code = xxPrefix(Code)
% doprefix  Replace @keywords with !keywords.

Code = regexprep(Code,'@([a-z]\w*)','!$1');

end % xxPrefix().

%**************************************************************************
function [Code,Labels,Export] ...
    = xxImport(Code,Params,Labels,Export,ParentFile,Opt)

% doimport  Import external file.
% Call import/include/input files with replacement.
pattern = '(?:!include|!input|!import)\((.*?)\)';
while true
    [tokens,start,finish] = ...
        regexp(Code,pattern,'tokens','start','end','once');
    if isempty(tokens)
        break
    end
    fname = strtrim(tokens{1});
    if ~isempty(fname)
        [impcode,Labels,Export] = preparser.readcode(fname, ...
            Params,Labels,Export,ParentFile,Opt);
        Code = [Code(1:start-1),impcode,Code(finish+1:end)];
    end
end

end % xxImport().

%**************************************************************************
function C = xxFormatError(C,Labels)

if iscell(C)
    for i = 1 : length(C)
        C{i} = xxFormatError(C{i},Labels);
    end
    return
end

%C = xxLabelsBack(C,Labels);
C = restore(C,Labels,'''%s''');
C = regexprep(C,'\s+',' ');
C = strtrim(C);
C = strfun.maxdisp(C,40);

end % xxFormatError().

function [C,Labels,Export] = controls(C,D,ErrParsing,Labels,Export)
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

startControls = preparser.xxStartControls();
[pos,command] = regexp(C,startControls,'once','start','match');
while ~isempty(pos)
    len = length(command);
    head = C(1:pos-1);
    command(1) = '';
    
    commandCap = [upper(command(1)),lower(command(2:end))];
    if ismatlab
        [s,tail,isError] = feval(['preparser.xxParse',commandCap],C,pos+len);
    else
        [s,tail,isError] = preparser.(['xxParse',commandCap])(C,pos+len);
    end
    if isError
        Error.code = C(pos:end);
        break
    end
    
    if ismatlab
    [replace,Labels,Error.exprsn,thisWarn] = ...
        feval(['preparser.xxReplace',commandCap],s,D,Labels,ErrParsing);
    else
        [replace,Labels,Error.exprsn,thisWarn] = ...
        preparser.(['xxReplace',commandCap])(s,D,Labels,ErrParsing);
    end
    
    if ~isempty(Error.exprsn)
        break
    end
    
    if ~isempty(thisWarn)
        warn = [warn,thisWarn]; %#ok<AGROW>
    end
    
    if strcmp(command,'export')
        Export = preparser.xxExport(s,Export,Labels);
    end
            
    C = [head,replace,tail];
    [pos,command] = regexp(C,startControls,'once','start','match');
end

if ~isempty(warn)
    warn = strtrim(warn);
    warn = restore(warn,Labels);
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

doErrors();


% Nested functions...


%**************************************************************************
    function doErrors()
        if ~isempty(Error.code)
            utils.error('preparser', [ErrParsing, ...
                'Something wrong with this control command(s) or commands nested inside: ''%s...''.'], ...
                preparser.xxFormatError(Error.code,Labels));
        end
        
        if ~isempty(Error.exprsn)
            utils.error('preparser', [ErrParsing, ...
                'Cannot evaluate this control expression: ''%s...''.'], ...
                preparser.xxFormatError(Error.exprsn,Labels));
        end
        
        if ~isempty(Error.leftover)
            utils.error('preparser', [ErrParsing, ...
                'This control command is miplaced or unfinished: ''%s...''.'], ...
                preparser.xxFormatError(Error.leftover,Labels));
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

[S.ForBody,Pos,match] = preparser.xxFindSubControl(C,Pos,'!do');
Err = ~strcmp(match,'!do');
if Err
    return
end

[S.DoBody,Pos,match] = preparser.xxFindEnd(C,Pos);
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

[If,Pos,match] = preparser.xxFindSubControl(C,Pos,{'!elseif','!else'});
Err = ~any(strcmp(match,{'!elseif','!else','!end'}));
if Err
    return
end
[S.IfCond,finish] = getcond(If);
S.IfBody = If(finish+1:end);

while strcmp(match,'!elseif')
    [Elseif,Pos,match] = preparser.xxFindSubControl(C,Pos,{'!elseif','!else'});
    Err = ~any(strcmp(match,{'!elseif','!else','!end'}));
    if Err
        return
    end
    [S.ElseifCond{end+1},finish] = getcond(Elseif);
    S.ElseifBody{end+1} = Elseif(finish+1:end);
end

if strcmp(match,'!else')
    [S.ElseBody,Pos,match] = preparser.xxFindEnd(C,Pos);
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

[S.SwitchExp,Pos,match] = preparser.xxFindSubControl(C,Pos,{'!case','!otherwise'});
Err = ~any(strcmp(match,{'!case','!otherwise','!end'}));
if Err
    return
end

while strcmp(match,'!case')
    [Case,Pos,match] = preparser.xxFindSubControl(C,Pos,{'!case','!otherwise'});
    Err = ~any(strcmp(match,{'!case','!otherwise','!end'}));
    if Err
        return
    end
    [S.CaseExp{end+1},finish] = getcond(Case);
    S.CaseBody{end+1} = Case(finish+1:end);
end

if strcmp(match,'!otherwise')
    [S.OtherwiseBody,Pos,match] = preparser.xxFindEnd(C,Pos);
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

[export,Pos,match] = preparser.xxFindEnd(C,Pos);
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
    = xxReplaceFor(S,D,Labels,ErrorParsing) %#ok<DEFNU>

Replace = '';
Err = '';
Warn = {};

forBody = S.ForBody;
doBody = S.DoBody;

if ~isempty(strfind(forBody,'!'))
    % We allow for `!if` commands inside the `!for` body, and hence need to
    % pre-parse the body first.
    forBody = preparser.controls(forBody,D,ErrorParsing,Labels);
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

% Expand `[ ... ]` in the `!for` body.
replaceFunc = @doExpandSqb; %#ok<NASGU>
forBody = regexprep(forBody,'\[[^\]]*\]','${replaceFunc($0)}');

if ~isempty(Err)
    return
end

% Remove `'name='` from `forbody` to get the RHS.
forBody = regexprep(forBody,[control,'\s*=\s*'],'');

% Itemize the RHS of the `!for` body.
list = regexp(forBody,'[^\s,;]+','match');

    function C1 = doExpandSqb(C)
        % doexpandsqb  Expand Matlab expressions in square brackets.
        C1 = '';
        try
            if ~isempty(plist)
                % Replace references to fieldnames of `'D'` with `'D.fieldname'`.
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
            Err = ['!for ',forBody];
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
        ptn = ['[',regexppattern(Labels),']'];
        % List of charcodes that actually occur in the `for` body.
        occur = regexp(C,ptn,'match');
        % The list of occurences is a cellstr of single characters; convert to
        % char vector.
        for k = [occur{:}]
            % Position of the charcode `k` in the storage.
            pos = position(Labels,k);
            % Copy the `pos`-th entry at the end.
            [Labels,newPos,newK] = copytoend(Labels,pos);
            % Create new entry in the storage.
            Labels.storage{newPos} ...
                = doSubsForControl(Labels.storage{newPos},control,list{i});
            C = strrep(C,k,char(newK));
        end
    end
    
    C = strfun.removeltel(C);
    Replace = [Replace,br,C]; %#ok
end

if isObsolete
    doBody = restore(doBody,Labels);
    utils.warning('obsolete', ...
        ['The syntax for lower/upper case of a !for control variable ', ...
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

[value,valid] = preparser.xxEval(S.IfCond,D,Labels);
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
    [value,valid] = preparser.xxEval(S.ElseifCond{i},D,Labels);
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

[switchexp,switchvalid] = preparser.xxEval(S.SwitchExp,D,Labels);
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
    [caseexp,valid] = preparser.xxEval(S.CaseExp{i},D,Labels);
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
startControls = preparser.xxStartControls();
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
startControls = preparser.xxStartControls();
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
Exp = restore(Exp,Labels);

% Evaluate the expression.
try
    Value = eval(Exp);
    Valid = true;
catch %#ok<CTCH>
    Value = false;
    Valid = false;
end

end % xxEval()


%**************************************************************************
function C = xxFormatError(C,Labels)

if iscell(C)
    for i = 1 : length(C)
        C{i} = preparser.xxFormatError(C{i},Labels);
    end
    return
end
C = restore(C,Labels);
C = regexprep(C,'\s+',' ');
C = strtrim(C);
C = strfun.maxdisp(C,40);

end % xxformatforerror()

    end % methods

end
