function s = parse(s,p)
% parse  [Not a public function] Parse sstate code.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

errorParsing = sprintf( ...
    'Error parsing file(s) <a href="matlab: edit %s">%s</a>. ', ...
    strrep(s.FName,' & ',' '),s.FName);

% Steady-state code file keywords:
% * !parameters or !input
% * !equations or !assignments
% * !growthname:= d?; or !growthname := ['d',lower(?)];
% * !growthname2imag
% * !solvefor
% * !log_variables
% * !all_but
% * !symbolic

code = p.Code;

% Mutliple, obsolete or auxiliary syntax.
code = multipleSyntax_(code);

% Find the user's template for growth names.
% The template can be either a simpel string using a ? to refer to the
% corresponding variable, e.g. d?, or a Matlab expression in square
% brackets, e.g. ['d',lower(?)].
tmpCode = restore(p.Code,p.Labels);
tkn = regexp(tmpCode,'!growthname\s*:=\s*([^;]+);','tokens','once');
if ~isempty(tkn) && ~isempty(tkn{1})
    s.growthnames = strtrim(tkn{1});
else
    s.growthnames = 'd?';
end

% Create a function handle for Matlab expressions.
if s.growthnames(1) == '[' && s.growthnames(end) == ']'
    s.growthnames = strrep(s.growthnames,'?','x');
    s.growthnames = mosw.str2func(['@(x) ',s.growthnames]);
end

% Read-in log declarations and remove them from `code`. They are considered
% global throughout the model so `!all_but` must be used consistently in all
% declarations.
[code,s.allbut,s.logs,invalid] = findlogs_(code);

if invalid
    utils.error('sstate',[errorParsing, ...
        'The keyword !all_but may appear in either all or none of ', ...
        'the !log_variables sections.']);
end

% Combine and process input blocks.
inputblock = '';
ptn = '!input.*?(?=!equations|$)';
if true % ##### MOSW
    replaceFunc = @doReplaceInp; %#ok<NASGU>
    code = regexprep(code,ptn,'${replaceFunc($0)}');
else
    code = mosw.dregexprep(code,ptn,doReplaceInp,0); %#ok<UNRCH>
end

% Throw away variable annotations.
inputblock = cleanup(inputblock,p.Labels);
input = uniquelist_(inputblock);

% @ *******************************************************************
    function c = doReplaceInp(list)
        c = '';
        list = strrep(list,'!input','');
        list = strtrim(list);
        inputblock = [list,sprintf('\n'),inputblock];
    end
% @ replaceInput_().

% Read equation blocks.
ptn = ['!equations\s*', ...
    '((',regexppattern(p.Labels),')?)', ...
    '\s*(.*?)\s*(?=!equations|$)'];
tkn = regexp(code,ptn,'tokens');

nBlock = numel(tkn);
block = cell(1,nBlock);
for i = 1 : nBlock
    s.label{i} = restore(tkn{i}{1},p.Labels,'delimiter=',false);
    s.label{i} = strtrim(s.label{i});
    block{i} = tkn{i}{2};
end

% Process equation blocks.
% Read equations, variables, log variables, and methods.
s.solvefor = cell([1,nBlock]);
for i = 1 : nBlock
    % Check for !symbolic.
    [tmpsymbolic,block{i}] = strfun.findremove(block{i},'!symbolic');
    % Check for !growthname2imag.
    [tmpg2i,block{i}] = strfun.findremove(block{i},'!growthname2imag');
    % Check for !solvefor variables.
    [tmpsolvefor,start,finish] = regexp(block{i}, ...
        '!solvefor\s*(.*?)\s*(?=!|$)','tokens','once','start','end');
    block{i}(start:finish) = '';
    if isempty(tmpsolvefor) && ~tmpg2i
        % No !solvefor or !growthname2imag found; this is an assignment
        % block.
        s.type{i} = 'assignment';
    elseif tmpg2i
        % This is a block converting growth names to imag parts of the
        % corresponding variables.
        s.type{i} = 'growthnames2imag';
        s.solvefor{i} = {};
        % Check that the block is otherwise empty.
        block{i} = strtrim(block{i});
        if ~isempty(block{i})
            utils.error('sstate',[errorParsing, ...
                'An !equations block with !growthname2imag ', ...
                'must be otherwise empty.']);
        end
    else
        % This is a block that will be solved numerically or symbolically.
        if tmpsymbolic
            s.type{i} = 'symbolic';
        else
            s.type{i} = 'numerical';
        end
        % Variables to solve for.
        s.solvefor{i} = regexp([tmpsolvefor{:}],'\w+','match');
    end
    % Read individual equations.
    block{i} = regexprep(block{i},'\s+','');
    block{i} = regexprep(block{i},';{2,}',';');
    s.eqtn{i} = regexp(block{i},'[^;]*?(?=;)','match');
    if strcmp(s.type{i},'assignment')
        % Find the LHS variables in assignments.
        s.solvefor{i} = regexp(s.eqtn{i},'^\s*(\w+)\s*(?==)','match','once');
        index = cellfun(@isempty,s.solvefor{i});
        s.solvefor{i}(index) = [];
    end
    % Create list of names that are already known before this block runs.
    if i == 1
        s.input{i} = input;
    else
        s.input{i} = [s.input{i-1},s.solvefor{i-1}];
    end
end

% Check multiple declarations of variables.
% Check number or equations and variables.
% Remove empty blocks.
invalid = {};
multiple = {};
emptyblock = false([1,nBlock]);
for i = 1 : nBlock
    if strcmp(s.type{i},'growthnames2imag')
        % Growthnames-to-imag blocks are always empty.
        continue
    end
    if isempty(s.eqtn{i}) && isempty(s.solvefor{i})
        emptyblock(i) = true;
        continue
    end
    if strcmp(s.type{i},'assignment')
        % Assignment blocks have no !solvefor declarations.
        continue
    end
    tmpsolvefor = s.solvefor{i};
    [~,index] = unique(tmpsolvefor);
    if length(tmpsolvefor) ~= length(index)
        tmpsolvefor(index) = [];
        for j = 1 : numel(tmpsolvefor)
            multiple{end+1} = i;
            multiple{end+1} = tmpsolvefor{j};
        end
    end
    if length(s.eqtn{i}) ~= length(s.solvefor{i})
        % # equations does not match # variables.
        invalid{end+1} = length(s.eqtn{i});
        invalid{end+1} = length(s.solvefor{i});
        invalid{end+1} = i;
    end
end

% Multiple declaration.
if ~isempty(multiple)
    utils.error('sstate',[errorParsing, ...
        'This variable is declared more than once in block #%g: ''%s''.'], ...
        multiple{:});
end

% Number of equations and number of variables do not match.
if ~isempty(invalid)
    utils.error('sstate',[errorParsing,'Number of equations (%g) ', ...
        'does not match number of variables (%g) in block #%g.'], ...
        invalid{:});
end

% Remove empty blocks.
if any(emptyblock)
    s.type(emptyblock) = [];
    s.input(emptyblock) = [];
    s.eqtn(emptyblock) = [];
    s.solvefor(emptyblock) = [];
    nBlock = numel(s.type);
end

% Check for presence of Symbolic Math Tbx reserved words.
reserved = {};
for i = 1 : nBlock
    if strcmp(s.type{i},'symbolic')
        list = sstate.chkreserved(s.eqtn{i},s.solvefor{i});
        if ~isempty(list)
            reserved = [reserved,list]; %#ok<AGROW>
        end
    end
end

if ~isempty(reserved)
    reserved = unique(reserved);
    utils.error('sstate',[errorParsing,'This is a reserved symbol ', ...
        'in Symbolic Math Tbx and cannot be used: ''%s''.'], ...
        reserved{:});
end

% Handle lags and leads.
% Use the growthname template to create auxiliary growth variables. Use
% additive or multiplicative growth depending on whether or not the
% variable is declared as log -- it is the user's responsibility to make
% this consistent with the model declarations.

% @ *******************************************************************
    function x = doReplaceTime(name,shiftstring)
        try
            shift = str2num(shiftstring);
        catch
            shift = [];
        end
        if ~isnumeric(shift) || isempty(shift) ...
                || isnan(shift) || isinf(shift) ...
                || shift ~= round(shift)
            invalidtime{end+1} = i;
            invalidtime{end+1} = [name,'{',shiftstring,'}'];
            x = '';
            return
        end
        if shift == 0
            x = name;
            return
        end
        gname = creategname(s,name);
        if islog_(name,s.logs,s.allbut)
            x = sprintf('(%s*(%s^(%g)))',name,gname,shift);
        else
            x = sprintf('(%s+(%s*(%g)))',name,gname,shift);
        end
        if ~any(strcmp(gname,s.input{i}))
            s.input{i}{end+1} = gname;
        end
    end
% @ replacetime().

invalidtime = {};
ptn = '(\<[a-zA-Z]\w*\>)\{(.*?)\}';
for i = 1 : nBlock
    % s.growth{i} = {};
    if true % ##### MOSW
        replaceTimeFunc = @doReplaceTime; %#ok<NASGU>
        s.eqtn{i} = regexprep(s.eqtn{i},ptn,'${replaceTimeFunc($1,$2)}');
    else
        s.eqtn{i} = mosw.dregexprep(s.eqtn{i},ptn,@doReplaceTime,[1,2]); %#ok<UNRCH>
    end
end

if ~isempty(invalidtime)
    error('iris:sstate', ...
        '\n*** Invalid time index in block #%g: ''%s''.',invalidtime{:});
end

end

% Subfunctions follow.

% @ ***********************************************************************
function [c,allbut,logs,invalid] = findlogs_(c)
% Read in all !log_variables sections.
invalid = false;
logs = regexp(c, ...
    '!log_variables(.*?)(?=!equations|!input|!solvefor|$)','tokens');
logs = [logs{:}];
c = regexprep(c, ...
    '!log_variables.*?(?=!equations|!input|!solvefor|$)','');
if isempty(logs)
    allbut = false;
    logs = {};
    return
end
nlogs = length(logs);
allbut = false([1,nlogs]);
for i = 1 : nlogs
    allbut(i) = strfun.findremove(logs{i},'!all_but');
end
invalid = any(allbut ~= allbut(1));
allbut = allbut(1);
logs = sprintf('%s ',logs{:});
logs = regexp(logs,'\w+','match');
if ~isempty(logs)
    logs = unique(logs);
end
end
% $ findallbutlogs_().

% @ ***********************************************************************
function list = uniquelist_(s)
list = regexp(s,'\w+','match');
list = unique(list);
end
% $ uniquelist_().

% $ ***********************************************************************
function flag = islog_(name,logs,allbut)
flag = any(strcmp(name,logs));
if allbut
    flag = ~flag;
end
end
% $ islog_().

% $ ***********************************************************************
function code = multipleSyntax_(code)
% Replace multiple, obsolete, or auxiliary syntax with proper syntax.
code = strrep(code,'!parameters','!input');
code = strrep(code,'!assign','!equations');
code = strrep(code,'!assign','!equations');
code = strrep(code,'!variables:positive','!log_variables');
code = strrep(code,'!variables:log','!log_variables');
code = strrep(code,'!growthnames','!growthname');
end
% $ multipleSyntax_().
