function [This,Assign] = myparse(This,P,Opt)
% myparse  [Not a public function] Parse model code.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

Assign = P.assign;

% Linear or non-linear model
%----------------------------

% Linear or non-linear model. First, check for the presence of th keyword
% `!linear` in the model code. However, if the user have specified the
% `'linear='` option in the `model` function, use that.
[This.linear,P.code] = strfun.findremove(P.code,'!linear');
if ~isempty(Opt.linear)
    This.linear = Opt.linear;
end

% Run the theta parser
%----------------------

% Run theparser on the model file.
the = theparser('model',P);
S = parse(the,Opt);

if ~Opt.declareparameters
    doDeclareParameters();
end

% Variables, shocks and parameters
%----------------------------------

blkOrder = [1,2,9,10,3,13];

% Read the individual names of variables, shocks, and parameters.
name = [S(blkOrder).name];
nameType = [S(blkOrder).nametype];
nameLabel = [S(blkOrder).namelabel];
nameAlias = [S(blkOrder).namealias];
nameValue = [S(blkOrder).namevalue];

% Re-type shocks.
shockType = nan(size(nameType));
shockType(nameType == 31) = 1; % Measurement shocks.
shockType(nameType == 32) = 2; % Transition shocks.
nameType(nameType == 31 | nameType == 32) = 3;

% Check the following naming rules:
%
% * Names must not start with 0-9 or _.
% * The name `ttrend` is a reserved name for time trend in `!dtrends`.
% * Shock names must not contain double scores because of the way
% cross-correlations are referenced.
%
invalid = ~cellfun(@isempty,regexp(name,'^[0-9_]','once')) ...
    | strcmp(name,'ttrend') ...
    | (~cellfun(@isempty,strfind(name,'__')) & nameType == 3);
if any(invalid)
    % Invalid variable or parameter names.
    utils.error('model',[utils.errorparsing(This), ....
        'This is not a valid variable, shock, or parameter name: ''%s''.'], ...
        name{invalid});
end

% Evaluate values assigned in the model code and/or in the `assign`
% database. Evaluate parameters first so that they are available for
% steady-state expressions.
nameValue = strtrim(nameValue);
nameValue = regexprep(nameValue,'(\<[A-Za-z]\w*\>)(?![\(\.])', ...
    '${utils.iff(any(strcmpi($1,{''Inf'',''NaN''})),$1,[''Assign.'',$1])}');
if isstruct(Assign) && ~isempty(Assign)
    donoteval = fieldnames(Assign);
else
    donoteval = {};
end
for iType = 5 : -1 : 1
    % Assign a value from declaration only if not in the input database.
    for j = find(nameType == iType)
        if isempty(nameValue{j}) || any(strcmp(name{j},donoteval))
            continue
        end
        try
            temp = eval(nameValue{j});
            if isnumeric(temp) && length(temp) == 1
                Assign.(name{j}) = temp;
            end
        catch %#ok<CTCH>
            Assign.(name{j}) = NaN;
        end
    end
end

% Find all names starting with `std_` or `corr_`.
stdInx = strncmp(name,'std_',4);
corrInx = strncmp(name,'corr_',5);

% Variables or shock names cannot start with `std_` or `corr_`.
invalid = (stdInx | corrInx) & nameType ~= 4;
if any(invalid)
    utils.error('model',[utils.errorparsing(This), ...
        'This is not a valid variable or shock name: ''%s''.'], ...
        name{invalid});
end

% Remove the declared `std_` and `corr_` names from the list of names.
if any(stdInx) || any(corrInx)
    stdName = name(stdInx);
    corrName = name(corrInx);
    name(stdInx | corrInx) = [];
    nameLabel(stdInx | corrInx) = [];
    nameAlias(stdInx | corrInx) = [];
    nameType(stdInx | corrInx) = [];
end

% Check for multiple names unless `'multiple=' true`.
if ~Opt.multiple
    nonUnique = strfun.nonunique(name);
    if ~isempty(nonUnique)
        utils.error('model',[utils.errorparsing(This), ...
            'This name is declared more than once: ''%s''.'], ...
            nonUnique{:});
    end
else
    % Take the last defined/assigned unique name.
    [name,inx] = unique(name,'last');
    nameType = nameType(inx);
    shockType = shockType(inx);
    nameLabel = nameLabel(inx);
    nameAlias = nameAlias(inx);
end

% Sort variable, shock and parameter names by the nametype.
[This.nametype,inx] = sort(nameType);
This.name = name(inx);
This.namelabel = nameLabel(inx);
This.namealias = nameAlias(inx);
shockType = shockType(inx);
shockType = shockType(This.nametype == 3);

% Check that std and corr names refer to valid shock names.
doChkStdcorrNames();

% Log variables
%---------------

This.log = false(size(This.name));
This.log(This.nametype == 1) = S(1).nameflag;
This.log(This.nametype == 2) = S(2).nameflag;

% Reporting equations
%---------------------

% TODO: Use theparser object instead of preparser object.
p1 = P;
p1.code = S(8).blk;
This.outside = reporting(p1);

% Read individual equations
%---------------------------

% There are four types of equations: measurement equations, transition
% equations, deterministic trends, and dynamic links.

% Read measurement equations.
[eqtn,eqtnF,eqtnS,eqtnLabel,eqtnAlias] = xxReadEqtns(S(5));
n = length(eqtn);
This.eqtn(end+(1:n)) = eqtn;
This.eqtnF(end+(1:n)) = eqtnF;
if ~This.linear
    This.eqtnS(end+(1:n)) = eqtnS;
else
    This.eqtnS(end+(1:n)) = {''};
end
This.eqtnlabel(end+(1:n)) = eqtnLabel;
This.eqtnalias(end+(1:n)) = eqtnAlias;
This.eqtntype(end+(1:n)) = 1;
This.nonlin(end+(1:n)) = false;

% Read transition equations; loss function is always moved to the end.

[eqtn,eqtnF,eqtnS,eqtnLabel,eqtnAlias,nonlin,lossDisc,multiple] ...
    = xxReadEqtns(S(6));

if ischar(lossDisc) && isempty(lossDisc)
    utils.error('model',[utils.errorparsing(This), ...
        'Loss function discount factor is empty.']);
end

if multiple
    utils.error('model',[utils.errorparsing(This), ...
        'Multiple loss functions found in the transition equations.']);
end

n = length(eqtn);
This.eqtn(end+(1:n)) = eqtn;
This.eqtnF(end+(1:n)) = eqtnF;
if ~This.linear
    This.eqtnS(end+(1:n)) = eqtnS;
else
    This.eqtnS(end+(1:n)) = {''};
end
This.eqtnlabel(end+(1:n)) = eqtnLabel;
This.eqtnalias(end+(1:n)) = eqtnAlias;
This.eqtntype(end+(1:n)) = 2;
This.nonlin(end+(1:n)) = nonlin;

% Check for empty dynamic equations. This may occur if the user types a
% semicolon between the full equations and its steady state version.
doChkEmptyEqtn();

This.multiplier = false(size(This.name));
isloss = ischar(lossDisc) && ~isempty(lossDisc);
if isloss
    % Create placeholders for new transition names (mutlipliers) and new
    % transition equations (derivatives of the loss function wrt existing
    % variables).
    lossPos = NaN;
    doLossFuncPlaceHolders();
end

% Introduce `nname` and `neqtn` only after we are done with placeholders
% for optimal policy variables and equations.
nName = length(This.name);
nEqtn = length(This.eqtn);

% Read deterministic trend equaitons.

[This,logMissing,invalid,multiple] = xxReadDtrends(This,S(7));

if ~isempty(logMissing)
    utils.error('model',[utils.errorparsing(This), ...
        'The LHS variable must be logarithmised in this dtrend equation: ''%s''.'], ...
        logMissing{:});
end

if ~isempty(invalid)
    utils.error('model',[utils.errorparsing(This), ...
        'Invalid LHS in this dtrend equation: ''%s''.'], ...
        invalid{:});
end

if ~isempty(multiple)
    utils.error('model',[utils.errorparsing(This), ...
        'Mutliple dtrend equations ', ...
        'for this measurement variable: ''%s''.'], ...
        multiple{:});
end

% Read dynamic links.

[This,invalid] = xxReadLinks(This,S(11));

if ~isempty(invalid)
    utils.error('model',[utils.errorparsing(This), ...
        'Invalid LHS in this dynamic link: ''%s''.'], ...
        invalid{:});
end

% Read autoexogenise definitions (variable/shock pairs).

[This,invalid,nonUnique] = xxReadAutoexogenise(This,S(12));

if ~isempty(invalid)
    utils.error('model',[utils.errorparsing(This), ...
        'Invalid autoexogenise definition: ''%s''.'], ...
        invalid{:});
end

if ~isempty(nonUnique)
    utils.error('model',[utils.errorparsing(This), ...
        'This shock is included in more than one ', ...
        'autoexogenise definitions: ''%s''.'], ...
        nonUnique{:});
end

% Process equations
%-------------------

% Remove label marks #(xx) from equations.
This.eqtn = regexprep(This.eqtn,'^\s*#\(\d+\)\s*','');

% Remove ! from math functions.
% This is for bkw compatibility only.
This.eqtnF = strrep(This.eqtnF,'!','');
if ~This.linear
    This.eqtnS = strrep(This.eqtnS,'!','');
end

% Remove blank spaces.
This.eqtn = regexprep(This.eqtn,{'\s+','".*?"'},{'',''});
This.eqtnF = regexprep(This.eqtnF,'\s+','');
if ~This.linear
    This.eqtnS = regexprep(This.eqtnS,'\s+','');
end

% Replace names with code characters.
nameOffset = 1999;
nameCode = char(nameOffset + (1:nName));

% Prepare patterns and their code substitutions for all variables,
% shocks, and parameter names.
codePatt = cell(1,nName);
codeRepl = cell(1,nName);
len = cellfun(@length,This.name);
[~,inx] = sort(len,2,'descend');
for i = inx
    codePatt{i} = ['\<',This.name{i},'\>'];
    codeRepl{i} = nameCode(i);
end
This.eqtnF = regexprep(This.eqtnF,codePatt,codeRepl);
if ~This.linear
    This.eqtnS = regexprep(This.eqtnS,codePatt,codeRepl);
end

% Try to catch undeclared names in all equations except dynamic links at
% this point; all valid names have been substituted for by the name codes.
% Do not do it in dynamic links because the links can contain std and corr
% names which have not been substituted for.
doChkUndeclared();

% Check for sstate references occuring in wrong places. Also replace
% the old syntax & with $.
doChkSstateRef();

% Max lag and lead
%------------------

maxT = max([S.maxt]);
minT = min([S.mint]);
if isloss
    % Anticipate that multipliers will have leads as far as the greatest lag.
    maxT = max([maxT,-minT]);
end
maxT = maxT + 1;
minT = minT - 1;
tZero = 1 - minT;
This.tzero = tZero;
nt = maxT - minT + 1;

% Replace name codes with with x(...)
%-------------------------------------

% Allocate ise the `occur` and `occurS` properties. These need to be
% allocated before we run `xxTransformEqtn` for the first time.
This.occur = sparse(false(length(This.eqtnF),length(This.name)*nt));
This.occurS = sparse(false(length(This.eqtnF),length(This.name)));

This = xxTransformEqtn(This,[],nameCode,Inf);

% Check equation syntax before we compute optimal policy.
doChkSyntax(Inf);

if isloss
    % Parse the discount factor first, as it can be a general expression.
    lossDisc = regexprep(lossDisc,codePatt,codeRepl);
    [This,lossDisc] = xxTransformEqtn(This,lossDisc,nameCode);
    
    % Create optimal policy equations by adding the derivatives
    % of the lagrangian wrt to the original transition variables. These
    % `naddeqtn` new equation will be put in place of the loss function
    % and the `naddeqtn-1` empty placeholders.
    [newEqtn,newEqtnF,NewNonlin] = myoptpolicy(This,lossPos,lossDisc);
    
    % Add the new equations to the model object, and parse them.
    last = find(This.eqtntype == 2,1,'last');
    This.eqtn(lossPos:last) = newEqtn(lossPos:last);
    This.eqtnF(lossPos:last) = newEqtnF(lossPos:last);
    This.eqtnF(lossPos:last) = ...
        regexprep(This.eqtnF(lossPos:last),codePatt,codeRepl);
    
    % Add sstate equations. Note that we must at least replace the old equation
    % in `losspos` position (which was the objective function) with the new
    % equation (which is a derivative wrt to the first variables).
    This.eqtnS(lossPos:last) = This.eqtnF(lossPos:last);
    
    This.nonlin(lossPos:last) = NewNonlin(lossPos:last);
    
    % Replace name codes with x(...) in the new F and S equations.
    This = xxTransformEqtn(This,[],nameCode,lossPos:last);
    
    % Check syntax of newly created optimal policy equations.
    doChkSyntax(lossPos:last);
end

% Finishing touches
%-------------------

% Vectorise *, /, \, ^ operators.
This.eqtnF = strfun.vectorise(This.eqtnF);

% Check the model structure.
[errMsg,errList] = xxChkStructure(This,shockType);
if ~isempty(errMsg)
    utils.error('model', ...
        [utils.errorparsing(This),errMsg],errList{:});
end

% Create placeholders for non-linearised equations.
This.eqtnN = cell(size(This.eqtn));
This.eqtnN(:) = {''};

% Make sure all equations end with semicolons.
for iEq = 1 : length(This.eqtn)
    if ~isempty(This.eqtn{iEq}) && This.eqtn{iEq}(end) ~= ';'
        This.eqtn{iEq}(end+1) = ';';
    end
    if ~isempty(This.eqtnF{iEq}) && This.eqtnF{iEq}(end) ~= ';'
        This.eqtnF{iEq}(end+1) = ';';
    end
    if ~isempty(This.eqtnS{iEq}) && This.eqtnS{iEq}(end) ~= ';'
        This.eqtnS{iEq}(end+1) = ';';
    end
end

% Nested functions.

%**************************************************************************
    function doDeclareParameters()
        
    % All declared names except parameters.
    inx = true(1,length(S));
    inx(3) = false;
    declaredNames = [S(inx).name];
    
    % All names occuring in equations.
    c = [S.eqtn];
    c = [c{:}];
    allNames = regexp(c,'\<[A-Za-z]\w*\>(?![\(\.])','match');
    allNames = unique(allNames);
    
    % Determine residual names.
    addNames = setdiff(allNames,declaredNames);
    
    % Re-create the parameter declaration section.
    nAdd = length(addNames);
    S(3).name = addNames;
    S(3).nametype = 4*ones(1,nAdd);
    tempCell = cell(1,nAdd);
    tempCell(:) = {''};
    S(3).namelabel = tempCell;
    S(3).namealias = tempCell;
    S(3).namevalue = tempCell;
    S(3).nameflag = false(1,nAdd);
    
end % doDeclareParameters().

%**************************************************************************
    function doChkStdcorrNames()
        
        if ~any(stdInx) && ~any(corrInx)
            % No std or corr names declared.
            return
        end
        
        if ~isempty(stdName)
            % Check that all std names declared by the user refer to a valid shock
            % name.
            [ans,pos] = mynameposition(This,stdName); %#ok<NOANS,ASGLU>
            invalid = stdName(isnan(pos));
            if ~isempty(invalid)
                utils.error('model',[utils.errorparsing(This), ...
                    'This is not a valid std deviation name: ''%s''.'], ...
                    invalid{:});
            end
        end
        
        if ~isempty(corrName)
            % Check that all corr names declared by the user refer to valid shock
            % names.
            [ans,pos] = mynameposition(This,corrName); %#ok<NOANS,ASGLU>
            invalid = corrName(isnan(pos));
            if ~isempty(invalid)
                utils.error('model',[utils.errorparsing(This), ...
                    'This is not a valid cross-correlation name: ''%s''.'], ...
                    invalid{:});
            end
        end
        
    end % doChkStdcorrNames().

%**************************************************************************
    function doChkUndeclared()
        % Undeclared names have not been substituted for by the name codes, except
        % std and corr names in dynamic links (std and corr names cannot be used in
        % other types of equations). Undeclared names in dynamic links will be
        % caught in `dochksyntax`. Distinguish variable names from function names
        % (func names are immediately followed by an opening bracket).
        % Unfortunately, `regexp` interprets high char codes as \w, so we need to
        % explicitly type the ranges.
        
        undeclared = {};
        stdcorr = {};
        for iiEq = find(This.eqtntype ~= 4)
            list = regexp(This.eqtnF{iiEq}, ...
                '\<[a-zA-Z][a-zA-Z0-9_]*\>(?![\(\.])','match');
            list = setdiff(unique(list),{'ttrend'});
            if ~isempty(list)
                for ii = 1 : length(list)
                    if strncmp(list{ii},'std_',4) ...
                            || strncmp(list{ii},'corr_',5)
                        stdcorr{end+1} = list{ii}; %#ok<AGROW>
                        stdcorr{end+1} = This.eqtn{iiEq}; %#ok<AGROW>
                    else
                        undeclared{end+1} = list{ii}; %#ok<AGROW>
                        undeclared{end+1} = This.eqtn{iiEq}; %#ok<AGROW>
                    end
                end
            end
        end
        
        % Report std or corr names used in equations other than links.
        if ~isempty(stdcorr)
            utils.error('model',[utils.errorparsing(This), ...
                'Std or corr name ''%s'' cannot be used in ''%s''.'], ...
                stdcorr{:});
        end

        % Report non-function names that have not been declared.
        if ~isempty(undeclared)
            utils.error('model',[utils.errorparsing(This), ...
                'Undeclared or mistyped name ''%s'' in ''%s''.'], ...
                undeclared{:});
        end
    end % doChkUndeclared().

%**************************************************************************
    function doChkSstateRef()
        % Check for sstate references in wrong places.
        func = @(c) ~cellfun(@(x) isempty(strfind(x,'&')),c);
        inx = func(This.eqtnF);
        % Not allowed in linear models.
        if This.linear
            if any(inx)
                utils.error('model',[utils.errorparsing(This), ...
                    'Steady-state references not allowed ', ...
                    'in linear models: ''%s''.'], ...
                    This.eqtn{inx});
            end
            return
        end
        inx = inx | func(This.eqtnS);
        % Not allowed in deterministic trends.
        temp = inx & This.eqtntype == 3;
        if any(temp)
            utils.error('model',[utils.errorparsing(This), ...
                'Steady-state references not allowed ', ...
                'in dtrends equations: ''%s''.'], ...
                This.eqtn{temp});
        end
        % Not allowed in dynamic links.
        temp = inx & This.eqtntype == 4;
        if any(temp)
            utils.error('model',[utils.errorparsing(This), ...
                'Steady-state references not allowed ', ...
                'in dynamic links: ''%s''.'], ...
                This.eqtn{temp});
        end
    end % doChkSstateRef().

%**************************************************************************
    function doLossFuncPlaceHolders()
        % Add new variables, i.e. the Lagrange multipliers associated with
        % all of the existing transition equations except the loss
        % function. These new names will be ordered first -- the logic is
        % that the final equations will be ordered as derivatives of the
        % lagrangian wrt to the individual variables.
        nAddEqtn = sum(This.nametype == 2) - 1;
        nAddName = sum(This.eqtntype == 2) - 1;
        % The default name is |'Mu_Eq%g'| but can be changed through the
        % option `'multiplierName='`.
        newName = cell(1,nAddName-1);
        for ii = 1 : nAddName
            newName{ii} = sprintf(Opt.multipliername,ii);
        end
        % Insert the new names between at the beginning of the blocks of existing
        % transition variables.
        preInx = This.nametype < 2;
        postInx = This.nametype >= 2;
        doInsert('name',newName);
        doInsert('nametype',2);
        doInsert('namelabel',{''});
        doInsert('namealias',{''});
        doInsert('log',false);
        doInsert('multiplier',true);
        % Loss function is always ordered last among transition equations.
        lossPos = length(This.eqtn);
        % We will add `naddeqtn` new transition equations, i.e. the
        % derivatives of the Lagrangiag wrt the existing transition
        % variables. At the same time, we will remove the loss function so
        % we need to create only `naddeqtn-1` placeholders.
        This.eqtn(end+(1:nAddEqtn)) = {''};
        This.eqtnF(end+(1:nAddEqtn)) = {''};
        This.eqtnS(end+(1:nAddEqtn)) = {''};
        This.eqtnlabel(end+(1:nAddEqtn)) = {''};
        This.eqtnalias(end+(1:nAddEqtn)) = {''};
        This.nonlin(end+(1:nAddEqtn)) = false;
        This.eqtntype(end+(1:nAddEqtn)) = 2;
        
        function doInsert(Field,New)
            if length(New) == 1 && nAddName > 1
                New = repmat(New,1,nAddName);
            end
            This.(Field) = [This.(Field)(preInx), ...
                New,This.(Field)(postInx)];
        end
        
    end % doLossFuncPlaceHolders().

%**************************************************************************
    function doChkSyntax(eqtnList)
        if isequal(eqtnList,Inf)
            eqtnList = 1 : nEqtn;
        end
        t = This.tzero;
        nName = length(This.name);
        nEqtn = length(This.eqtn);
        ne = sum(This.nametype == 3);
        std = double(This.linear)*1 + double(~This.linear)*0.1;
        x = rand(1,nName,nt);
        % This is the test vector for dynamic links. In dynamic links, we allow std
        % and corr names to occurs, and append them to the assign vector.
        if any(This.eqtntype == 4)
            x1 = [rand(1,nName,1),std*ones(1,ne),zeros(1,ne*(ne-1)/2)];
        end
        L = x(1,:,t);
        dx = zeros(1,nName,nt);
        tTrend = 0;
        g = zeros(sum(This.nametype == 5),1);
        undeclared = {};
        syntax = {};
        for eq = eqtnList
            eqtnF = This.eqtnF{eq};
            if isempty(eqtnF)
                continue
            end
            if eq <= length(This.eqtnS) && This.eqtntype(eq) <= 2
                eqtnS = This.eqtnS{eq};
                eqtnS = strrep(eqtnS,'exp?','exp');
            end
            try
                eqtnF = strfun.vectorise(eqtnF);
                eqtnF = str2func(['@(x,dx,L,t,ttrend,g)',eqtnF]);
                if This.eqtntype(eq) < 4
                    eqtnF(x,dx,L,t,tTrend,g);
                else
                    % Evaluate RHS of dynamic links. They can refer to std or corr names, so we
                    % have to use the `x1` vector.
                    eqtnF(x1,[],[],1,[],g);
                end
                if eq <= length(This.eqtnS) && This.eqtntype(eq) <= 2 ...
                        && ~isempty(eqtnS)
                    eqtnS = str2func(['@(x,dx,L,t,ttrend,g)',eqtnS]);
                    eqtnS(x,dx,L,t,tTrend,g);
                end
            catch E
                % Undeclared names should have been already caught. But a few exceptions
                % may still exist.
                [match,tokens] = ...
                    regexp(E.message,'Undefined function or variable ''(\w*)''','match','tokens','once');
                if ~isempty(match)
                    undeclared{end+1} = tokens{1}; %#ok<AGROW>
                    undeclared{end+1} = This.eqtn{eq}; %#ok<AGROW>
                else
                    message = E.message;
                    syntax{end+1} = This.eqtn{eq}; %#ok<AGROW>
                    if ~isempty(message) && message(end) ~= '.'
                        message(end+1) = '.'; %#ok<AGROW>
                    end
                    syntax{end+1} = message; %#ok<AGROW>
                end
            end
        end
        if ~isempty(undeclared)
            utils.error('model',[utils.errorparsing(This), ...
                'Undeclared or mistyped name ''%s'' in ''%s''.'], ...
                undeclared{:});
        end
        if ~isempty(syntax)
            utils.error('model',[utils.errorparsing(This), ...
                'Syntax error in ''%s''.\n', ...
                '\tMatlab says: %s'], ...
                syntax{:});
        end
    end % doChkSyntax().

%**************************************************************************
    function doChkEmptyEqtn()
        % dochkemptyeqtn  Check for empty full equations.
        emptyInx = cellfun(@isempty,This.eqtnF);
        if any(emptyInx)
            utils.error('model',[utils.errorparsing(This), ...
                'This equation is empty: ''%s''.'], ...
                This.eqtn{emptyInx});
        end
    end % doChkEmptyeEtn().

end

% Subfunctions.

%**************************************************************************
function [Eqtn,EqtnF,EqtnS,EqtnLabel,EqtnAlias, ...
    EqtnNonlin,LossDisc,Multiple] ...
    = xxReadEqtns(S)
% xxreadeqtns  Read measurement or transition equations.

Eqtn = cell(1,0);
EqtnLabel = cell(1,0);
EqtnAlias = cell(1,0);
EqtnF = cell(1,0);
EqtnS = cell(1,0);
EqtnNonlin = false(1,0);
LossDisc = NaN;
Multiple = false;

if isempty(S.eqtn)
    return
end

% Check for a loss function and its discount factor first if requested by
% the caller. This is done for transition equations only.
if nargout >= 6
    doLossFunc();
end

Eqtn = S.eqtn;
EqtnLabel = S.eqtnlabel;
EqtnAlias = S.eqtnalias;
EqtnNonlin = strcmp(S.eqtnsign,'=#');

neqtn = length(S.eqtn);
EqtnF = strfun.emptycellstr(1,neqtn);
EqtnS = strfun.emptycellstr(1,neqtn);
for iEq = 1 : neqtn
    if ~isempty(S.eqtnlhs{iEq})
        EqtnF{iEq} = [S.eqtnlhs{iEq},'-(',S.eqtnrhs{iEq},')'];
    else
        EqtnF{iEq} = S.eqtnrhs{iEq};
    end
    if ~isempty(S.sstaterhs{iEq})
        if ~isempty(S.sstatelhs{iEq})
            EqtnS{iEq} = [S.sstatelhs{iEq},'-(',S.sstaterhs{iEq},')'];
        else
            EqtnS{iEq} = S.sstaterhs{iEq};
        end
    end
end

    function doLossFunc()
        % doLossFunc  Find loss function amongst equations.
        start = regexp(S.eqtnrhs,'^min#?\(','once');
        lossInx = ~cellfun(@isempty,start);
        if sum(lossInx) == 1
            % Order the loss function last.
            list = {'eqtn','eqtnlabel','eqtnalias', ...
                'eqtnlhs','eqtnrhs','eqtnsign', ...
                'sstatelhs','sstaterhs','sstatesign'};
            for i = 1 : length(list)
                S.(list{i}) = [S.(list{i})(~lossInx), ...
                    S.(list{i})(lossInx)];
            end
            S.eqtnlhs{end} = '';
            S.eqtnrhs{end} = strrep(S.eqtnrhs{end},'#','');
            % Get the discount factor from inside of the min(...) brackets.
            [close,LossDisc] = strfun.matchbrk(S.eqtnrhs{end},4);
            % Remove the min operator.
            S.eqtnrhs{end} = S.eqtnrhs{end}(close+1:end);
        elseif sum(lossInx) > 1
            Multiple = true;
        end
    end % doLossFunc().

end % xxReadEqtns().

%**************************************************************************
function [This,LogMissing,Invalid,Multiple] = xxReadDtrends(This,S)

n = sum(This.nametype == 1);
eqtn = strfun.emptycellstr(1,n);
eqtnF = strfun.emptycellstr(1,n);
eqtnlabel = strfun.emptycellstr(1,n);
eqtnalias = strfun.emptycellstr(1,n);

% Create list of measurement variable names against which the LHS of
% dtrends equations will be matched. Add log(...) for log variables.
list = This.name(This.nametype == 1);
islog = This.log(This.nametype == 1);
loglist = list;
loglist(islog) = regexprep(loglist(islog),'(.*)','log($1)','once');

neqtn = length(S.eqtn);
logmissing = false(1,neqtn);
invalid = false(1,neqtn);
multiple = false(1,neqtn);
for iEq = 1 : length(S.eqtn)
    index = find(strcmp(loglist,S.eqtnlhs{iEq}),1);
    if isempty(index)
        if any(strcmp(list,S.eqtnlhs{iEq}))
            logmissing(iEq) = true;
        else
            invalid(iEq) = true;
        end
        continue
    end
    if ~isempty(eqtn{index})
        multiple(iEq) = true;
        continue
    end
    eqtn{index} = S.eqtn{iEq};
    eqtnF{index} = S.eqtnrhs{iEq};
    eqtnlabel{index} = S.eqtnlabel{iEq};
    eqtnalias{index} = S.eqtnalias{iEq};
end

LogMissing = S.eqtn(logmissing);
Invalid = S.eqtn(invalid);
Multiple = S.eqtnlhs(multiple);
if any(multiple)
    Multiple = unique(Multiple);
end

This.eqtn(end+(1:n)) = eqtn;
This.eqtnF(end+(1:n)) = eqtnF;
This.eqtnS(end+(1:n)) = {''};
This.eqtnlabel(end+(1:n)) = eqtnlabel;
This.eqtnalias(end+(1:n)) = eqtnalias;
This.eqtntype(end+(1:n)) = 3;
This.nonlin(end+(1:n)) = false;

end % xxReadDtrends().

%**************************************************************************
function [This,Invalid] = xxReadLinks(This,S)

nname = length(This.name);
neqtn = length(S.eqtn);

valid = false(1,neqtn);
refresh = nan(1,neqtn);
for iEq = 1 : neqtn
    if isempty(S.eqtn{iEq})
        continue
    end
    [assignInx,stdcorrInx] = modelobj.mynameindex( ...
        This.name,This.name(This.nametype == 3),S.eqtnlhs{iEq});
    %index = strcmp(This.name,S.eqtnlhs{iEq});
    if any(assignInx)
        % The LHS name is a variable, shock, or parameter name.
        valid(iEq) = true;
        refresh(iEq) = find(assignInx);
    elseif any(stdcorrInx)
        % The LHS name is a std or corr name.
        valid(iEq) = true;
        refresh(iEq) = nname + find(stdcorrInx);
    end
end

Invalid = S.eqtn(~valid);
This.eqtn(end+(1:neqtn)) = S.eqtn;
This.eqtnF(end+(1:neqtn)) = S.eqtnrhs;
This.eqtnS(end+(1:neqtn)) = {''};
This.eqtnlabel(end+(1:neqtn)) = S.eqtnlabel;
This.eqtnalias(end+(1:neqtn)) = S.eqtnalias;
This.eqtntype(end+(1:neqtn)) = 4;
This.nonlin(end+(1:neqtn)) = false;
This.Refresh = refresh;

end % xxReadLinks().

%**************************************************************************
function [This,Invalid,Nonunique] = xxReadAutoexogenise(This,S)

% `This.Autoexogenise` is reset to NaNs within `myautoexogenise`.
[This,invalid,Nonunique] = myautoexogenise(This,S.eqtnlhs,S.eqtnrhs);
Invalid = S.eqtn(invalid);

end % xxReadautoExogenise().

%**************************************************************************
function [This,Eqtn] = xxTransformEqtn(This,Eqtn,NameCode,Eqs)
% xxTransformEqtn  Replace numerical codes with x() and the names of stds
% and corrs with s().

ftransform = @doFTransform; %#ok<NASGU>
stransform = @doSTransform; %#ok<NASGU>
stdcorr = @doStdcorr; %#ok<NASGU>
pattern = ['([&])?([',NameCode(1),'-',NameCode(end),'])(\{[\+\-]\d+\})?'];
stdcorrPattern = '\<(std|corr)_[a-zA-Z]\w*\>';

nameOffset = double(NameCode(1)) - 1;
tZero = This.tzero;

if ischar(Eqtn) && ~isempty(Eqtn)
    % Transform a single equation passed in as a text string.
    Eqtn = regexprep(Eqtn,pattern,'${ftransform($1,$2,$3,NaN)}');
    return
end

nEqtn = length(This.eqtnF);
nName = length(This.name);
nt = size(This.occur,2) / nName;
occurF = reshape(full(This.occur),[nEqtn,nName,nt]);
occurS = full(This.occurS);

if isequal(Eqs,Inf)
    Eqs = 1 : nEqtn;
end

% We need to pass the equation number, `iEq`, into the nested functions. We
% therefore use a `for` loop, and not a single `regexprep` command.
for iEq = Eqs
    
    if isempty(This.eqtnF{iEq})
        continue
    end
    
    % If no steady-state version exists, copy the dynamic equation.
    if ~This.linear && This.eqtntype(iEq) <= 2 && isempty(This.eqtnS{iEq})
        This.eqtnS{iEq} = This.eqtnF{iEq};
    end
    
    % Steady-state equations.
    if ~isempty(This.eqtnS{iEq})
        This.eqtnS{iEq} = regexprep(This.eqtnS{iEq},pattern, ...
            '${stransform($1,$2,$3,iEq)}');
    end
    
    % Full dynamic equations.
    This.eqtnF{iEq} = regexprep(This.eqtnF{iEq},pattern, ...
        '${ftransform($1,$2,$3,iEq)}');
    
    % Allow std_ and corr_ names only in dynamic links.
    if This.eqtntype(iEq) == 4
        This.eqtnF{iEq} = regexprep(This.eqtnF{iEq}, ...
            stdcorrPattern,'${stdcorr($0)}');
    end
    
end

This.occur = sparse(occurF(:,:));
This.occurS = sparse(occurS);

    function C = doFTransform(C0,C1,C2,iEq)
        % Replace name codes with x vector in dynamic equations.
        % c0 can be empty or '&'.
        % c1 is the name code, e.g. char(highChar+number).
        % c2 is empty or the time subscript, e.g. {-1}.
        % Variable or parameter number.
        realid = double(C1) - nameOffset;
        if realid < 1 || realid > length(This.nametype)
            % Undeclared name. Will be captured later.
            C = [C1,C2];
            return
        end
        if isempty(C2)
            t = 0;
        else
            C2 = C2(2:end-1);
            t = sscanf(C2,'%g');
        end
        switch This.nametype(realid)
            case {1,2}
                % Measurement and transition variables.
                if t == 0
                    time = 't';
                else
                    time = sprintf('t%+g',t);
                end
                if isempty(C0)
                    C = sprintf('x(:,%g,%s)',realid,time);
                    if isfinite(iEq)
                        occurF(iEq,realid,tZero+t) = true;
                    end
                else
                    % Steady-state level reference.
                    C = sprintf('L(:,%g)',realid);
                end
            case 3
                % Shocks.
                if isempty(C0)
                    C = sprintf('x(:,%g,t)',realid);
                    if isfinite(iEq)
                        occurF(iEq,realid,tZero+t) = true;
                    end
                else
                    C = '0';
                end
            case 4
                % Parameters.
                C = sprintf('x(:,%g,t)',realid);
                if isfinite(iEq)
                    % Allow for parameter lags/leads in model equations, but automatically
                    % reset them to t+0.
                    %occurF(iEq,realid,tZero+t) = true;
                    occurF(iEq,realid,tZero) = true;
                end
            case 5
                % Exogenous variables in dtrend equations.
                C = sprintf('g(%g,:)',realid-sum(This.nametype < 5));
                if isfinite(iEq)
                    occurF(iEq,realid,tZero+t) = true;
                end
        end
    end % doFTransform().

    function C = doSTransform(C0,C1,C2,iEq) %#ok<INUSL>
        % Replace name codes with x vector in sstate equations.
        % c0 is not used.
        % Variable or parameter number.
        realid = double(C1) - nameOffset;
        if realid < 1 || realid > length(This.nametype)
            % Undeclared name. Will be captured later.
            C = [C1,C2];
            return
        end
        if isempty(C2)
            t = 0;
        else
            C2 = C2(2:end-1);
            t = sscanf(C2,'%g');
        end
        switch This.nametype(realid)
            case 1
                % Measurement variables.
                C = sprintf('x(%g)',realid);
                if This.log(realid)
                    C = ['exp?(',C,')'];
                end
            case 2
                % Transition variables.
                if t == 0
                    if ~This.log(realid)
                        C = sprintf('x(%g)',realid);
                    else
                        C = sprintf('exp?(x(%g))',realid);
                    end
                else
                    if ~This.log(realid)
                        C = sprintf('(x(%g)+(%g)*dx(%g))',realid,t,realid);
                    else
                        C = sprintf('(exp?(x(%g))*exp?(dx(%g))^(%g))', ...
                            realid,realid,t);
                    end
                end
            case 3
                % Shocks.
                C = '0';
            case 4
                % Parameters.
                C = sprintf('x(%g)',realid);
            case 5
                % Exogenous variables in dtrend equations.
                C = 'NaN';
        end
        if ~isinf(iEq)
            occurS(iEq,realid) = true;
        end
    end % doSTransform().

    function c = doStdcorr(c)
        inx = modelobj.mystdcorrindex(This,c);
        if any(inx)
            n = find(inx);
            c = sprintf('x(:,%g,t)',nName+n);
        end
    end % doStdcorr().

end % xxTransformEqtn().

%**************************************************************************
function [ErrMsg,ErrList] = xxChkStructure(This,shockType)

nEqtn = length(This.eqtn);
nName = length(This.name);
nt = size(This.occur,2) / nName;
occurF = reshape(full(This.occur),[nEqtn,nName,nt]);
tZero = This.tzero;

ErrMsg = '';
ErrList = {};

% Lags and leads.
tt = true(1,size(occurF,3));
tt(tZero) = false;

% At least one transition variable.
if ~any(This.nametype == 2)
    ErrMsg = 'No transition variable.';
    return
end

% At least one transition equation. This could be caused by the user's not
% ending equations with semicolons.
if ~any(This.eqtntype == 2)
    ErrMsg = ['No transition equation. ', ...
        'Have you used a semicolon at the end of each equation?'];
    return
end

% Current dates of all transition variables.
aux = ~any(occurF(This.eqtntype == 2,This.nametype == 2,tZero),1);
if any(aux)
    ErrList = This.name(This.nametype == 2);
    ErrList = ErrList(aux);
    ErrMsg = ...
        'No current date of this transition variable: ''%s''.';
    return
end

% Current dates of all measurement variables.
aux = ~any(occurF(This.eqtntype == 1,This.nametype == 1,tZero),1);
if any(aux)
    ErrList = This.name(This.nametype == 1);
    ErrList = ErrList(aux);
    ErrMsg = ...
        'No current date of this measurement variable: ''%s''.';
    return
end

% At least one transition variable in each transition equation.
valid = any(any(occurF(This.eqtntype == 2,This.nametype == 2,:),3),2);
if any(~valid)
    ErrList = This.eqtn(This.eqtntype == 2);
    ErrList = ErrList(~valid);
    ErrMsg = ...
        'No transition variable in this transition equation: ''%s''.';
    return
end

% At least one measurement variable in each measurement equation.
valid = any(any(occurF(This.eqtntype == 1,This.nametype == 1,:),3),2);
if any(~valid)
    ErrList = This.eqtn(This.eqtntype == 1);
    ErrList = ErrList(~valid);
    ErrMsg = ...
        'No measurement variable in this measurement equation: ''%s''.';
    return
end

% # measurement equations == # measurement variables.
nme = sum(This.eqtntype == 1);
nmv = sum(This.nametype == 1);
if nme ~= nmv
    ErrMsg = sprintf( ...
        '%g measurement equation(s) for %g measurement variable(s).', ...
        nme,nmv);
    return
end

% # transition equations == # transition variables.
nte = sum(This.eqtntype == 2);
ntv = sum(This.nametype == 2);
if nte ~= ntv
    ErrMsg = sprintf(['%g transition equation(s) ', ...
        'for %g transition variable(s).'],nte,ntv);
    return
end

% No lags/leads of measurement variables.
aux = any(any(occurF(:,This.nametype == 1,tt),3),1);
if any(aux)
    ErrList = This.name(This.nametype == 1);
    ErrList = ErrList(aux);
    ErrMsg = ...
        'This measurement variable occurs with a lag/lead: ''%s''.';
    return
end

% No lags/leads of shocks.
aux = any(any(occurF(:,This.nametype == 3,tt),3),1);
if any(aux)
    ErrList = This.name(This.nametype == 3);
    ErrList = ErrList(aux);
    ErrMsg = 'This shock occurs with a lag/lead: ''%s''.';
    return
end

% No lags/leads of parameters.
aux = any(any(occurF(:,This.nametype == 4,tt),3),1);
if any(aux)
    ErrList = This.name(This.nametype == 4);
    ErrList = ErrList(aux);
    ErrMsg = 'This parameter occurs with a lag/lead: ''%s''.';
    return
end

% No lags/leads of exogenous variables.
check = any(any(occurF(:,This.nametype == 5,tt),3),1);
if any(check)
    ErrList = This.name(This.nametype == 4);
    ErrList = ErrList(check);
    ErrMsg = 'This exogenous variables occurs with a lag/lead: ''%s''.';
    return
end

% No measurement variables in transition equations.
aux = any(any(occurF(This.eqtntype == 2,This.nametype == 1,:),3),2);
if any(aux)
    ErrList = This.eqtn(This.eqtntype == 2);
    ErrList = ErrList(aux);
    ErrMsg = ['This transition equation refers to ', ...
        'measurement variable(s): ''%s''.'];
    return
end

% No leads of transition variables in measurement equations.
tt = true([1,size(occurF,3)]);
tt(1:tZero) = false;
aux = any(any(occurF(This.eqtntype == 1,This.nametype == 2,tt),3),2);
if any(aux)
    ErrList = This.eqtn(This.eqtntype == 1);
    ErrList = ErrList(aux);
    ErrMsg = ['Lead(s) of transition variable(s) in this ', ...
        'measurement equation: ''%s''.'];
    return
end

% Current date of any measurement variable in each measurement
% equation.
aux = ~any(occurF(This.eqtntype == 1,This.nametype == 1,tZero),2);
if any(aux)
    ErrList = This.eqtn(This.eqtntype == 1);
    ErrList = ErrList(aux);
    ErrMsg = ['No current-dated measurement variables ', ...
        'in this measurement equation: ''%s''.'];
    return
end

if any(This.nametype == 3)
    % Find shocks in measurement equations.
    check1 = any(occurF(This.eqtntype == 1,This.nametype == 3,tZero),1);
    % Find shocks in transition equations.
    check2 = any(occurF(This.eqtntype == 2,This.nametype == 3,tZero),1);
    % No measurement shock in transition equations.
    aux = check2 & shockType == 1;
    if any(aux)
        ErrList = This.name(This.nametype == 3);
        ErrList = ErrList(aux);
        ErrMsg = ['This measurement shock occurs ', ...
            'in transition equation(s): ''%s''.'];
        return
    end
    % No transition shock in measurement equations.
    aux = check1 & shockType == 2;
    if any(aux)
        ErrList = This.name(This.nametype == 3);
        ErrList = ErrList(aux);
        ErrMsg = ['This transition shock occurs ', ...
            'in measurement equation(s): ''%s''.'];
        return
    end
end

% Only parameters and exogenous variables can occur in deterministic trend
% equations.
rows = This.eqtntype == 3;
cols = This.nametype < 4;
check = any(any(occurF(rows,cols,:),3),2);
if any(check)
    ErrList = This.eqtn(rows);
    ErrList = ErrList(check);
    ErrMsg = ['This dtrend equation ', ...
        'refers to name(s) ', ...
        'other than parameters or exogenous variables: ''%s''.'];
    return
end

% Exogenous variables only in dtrend equations.
rows = This.eqtntype ~= 3;
cols = This.nametype == 5;
check = any(any(occurF(rows,cols,:),3),2);
if any(check)
    ErrList = This.eqtn(rows);
    ErrList = ErrList(check);
    ErrMsg = ['Exogenous variables allowed only in ', ...
        'dtrend equations: ''%s''.'];
    return
end

end % xxChkStructure().
