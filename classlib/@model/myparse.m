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

    function C = doReplaceNameValue(C)
        if any(strcmpi(C,{'Inf','Nan'}))
            return
        end
        C = ['Assign.',C];
    end

nameValue = strtrim(nameValue);
ptn = '\<[A-Za-z]\w*\>(?![\(\.])';
rplFunc = @doReplaceNameValue; %#ok<NASGU>
nameValue = regexprep(nameValue,ptn,'${rplFunc(C1)}');
if isstruct(Assign) && ~isempty(Assign)
    doNotEvalList = fieldnames(Assign);
else
    doNotEvalList = {};
end
for iType = 5 : -1 : 1
    % Assign a value from declaration only if not in the input database.
    for j = find(nameType == iType)
        if isempty(nameValue{j}) || any(strcmp(name{j},doNotEvalList))
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

[eqtn,eqtnF,eqtnS,eqtnLabel,eqtnAlias,nonlin,isLoss,multipleLoss] ...
    = xxReadEqtns(S(6));

if multipleLoss
    utils.error('model',[utils.errorparsing(This), ...
        'Multiple loss functions found in transition equations.']);
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
if isLoss
    % Create placeholders for new transition names (mutlipliers) and new
    % transition equations (derivatives of the loss function wrt existing
    % variables).
    lossPos = NaN;
    doLossPlaceHolders();
end

% Read deterministic trend equaitons.

[This,logMissing,invalid,multipleLoss] = xxReadDtrends(This,S(7));

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

if ~isempty(multipleLoss)
    utils.error('model',[utils.errorparsing(This), ...
        'Mutliple dtrend equations ', ...
        'for this measurement variable: ''%s''.'], ...
        multipleLoss{:});
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

nName = length(This.name);
nEqtn = length(This.eqtn);

% Delete charcode from equations.
This.eqtn = cleanup(This.eqtn,P.labels);

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

% Max lag and lead
%------------------

maxT = max([S.maxt]);
minT = min([S.mint]);
if isLoss
    % Anticipate that multipliers will have leads as far as the greatest lag.
    maxT = max([maxT,-minT]);
end
maxT = maxT + 1;
minT = minT - 1;
tZero = 1 - minT;
This.tzero = tZero;
nt = maxT - minT + 1;

% Replace variables names with code names
%-----------------------------------------

% Check for sstate references occuring in wrong places. Also replace
% the old syntax & with $.
doChkSstateRef();

This.occur = false(nEqtn,nName*nt);
This.occurS = false(nEqtn,nName);

[namePatt,nameReplF,nameReplS] = mynamepattrepl(This);

if ~This.linear
    % If no steady-state version exists, copy the full equation.
    isEmptySstate = cellfun(@isempty,This.eqtnS) & This.eqtntype <= 2;
    This.eqtnS(isEmptySstate) = This.eqtnF(isEmptySstate);
    This.eqtnS(This.eqtntype > 2) = {''};
    
    This.eqtnS = regexprep(This.eqtnS,namePatt,nameReplS);
    
    % Remove steady-state references from steady-state equations; they are
    % treated as the respective variables.
    This.eqtnS = strrep(This.eqtnS,'&(%','(%');
    This.eqtnS = strrep(This.eqtnS,'&exp(%','exp(%');
    
    This.eqtnS = regexprep(This.eqtnS, ...
        '\(%\(@(\d+)\)\)\{([+\-]\d+)\}', ...
        '(%(@$1)$2*dx(@$1))');
else
    This.eqtnS(:) = {''};
end

% Full equations
%----------------

This.eqtnF = regexprep(This.eqtnF,namePatt,nameReplF);

% Steady-state references.
% Replace &%(:,@10,!) with &(:,@10).
This.eqtnF = regexprep(This.eqtnF,'&%\(:,@(\d+),!\)','&(:,@$1)');

% Replace %(:,@10,!){+2} with %(:,@10,!)(+2).
This.eqtnF = strrep(This.eqtnF,'!){','!)(');
This.eqtnF = strrep(This.eqtnF,'}',')');

% Replace %(:,@10,!)(+2) with %(:,@10,!+2).
This.eqtnF = strrep(This.eqtnF,'!)(-','!-');
This.eqtnF = strrep(This.eqtnF,'!)(+','!+');

% Try to catch undeclared names in all equations except dynamic links at
% this point; all valid names have been substituted for by %(...) and
% ?(...). Do not do it in dynamic links because the links can contain std
% and corr names which have not been substituted for.
doChkUndeclared();

% Replace control characters.
This.eqtnS = strrep(This.eqtnS,'%','x');
This.eqtnS = strrep(This.eqtnS,'@','');
This.eqtnF = strrep(This.eqtnF,'&(:,@','L(:,');
This.eqtnF = strrep(This.eqtnF,'?(@','g(');
This.eqtnF = strrep(This.eqtnF,'%','x');
This.eqtnF = strrep(This.eqtnF,'!','t');
This.eqtnF = strrep(This.eqtnF,'@','');

% Check for orphan { and & after we have substituted for the valid
% references.
doChkTimeSsref();

% Find the occurences of variable, shocks, and parameters in individual
% equations.
This = myoccurence(This,Inf);

if isLoss
    % Find the closing bracket in min(...), retrieve the discount factor, and
    % remove the whole term from the loss function equation.
    [close,lossDisc] = strfun.matchbrk(This.eqtnF{lossPos},4);
    if isempty(close)
        utils.error('model:myparse',[utils.errorparsing(This), ...
            'Syntax error in the loss function.']);
    end
    if isempty(lossDisc)
        utils.error('model',[utils.errorparsing(This), ...
            'Loss function discount factor is empty.']);
    end
    This.eqtnF{lossPos}(1:close) = '';
end

% Check equation syntax before we compute optimal policy but after we
% remove the header min(...) from the loss function equation.
if Opt.chksyntax
    mychksyntax(This);
end

if isLoss
    % Create optimal policy equations by adding the derivatives of the
    % lagrangian wrt to the original transition variables. These `naddeqtn` new
    % equation will be put in place of the loss function and the `naddeqtn-1`
    % empty placeholders.
    [newEqtn,newEqtnF,newEqtnS,NewNonlin] ...
        = myoptpolicy(This,lossPos,lossDisc);
    
    % Add the new equations to the model object, and parse them.
    last = find(This.eqtntype == 2,1,'last');
    This.eqtn(lossPos:last) = newEqtn(lossPos:last);
    This.eqtnF(lossPos:last) = newEqtnF(lossPos:last);
    
    if ~This.linear
        % Add sstate equations. Note that we must at least replace the old equation
        % in `lossPos` position (which was the objective function) with the new
        % equation (which is a derivative wrt to the first variables).
        This.eqtnS(lossPos:last) = newEqtnS(lossPos:last);
        % Update the nonlinear equation flags.
        This.nonlin(lossPos:last) = NewNonlin(lossPos:last);
    end
    
    % Update occurence arrays with new equations.
    This = myoccurence(This,lossPos:last);
end

% Finishing touches
%-------------------

% Sparse occurence arrays.
This.occur = sparse(This.occur(:,:));
This.occurS = sparse(This.occurS);

% Check the model structure.
[errMsg,errList] = xxChkStructure(This,shockType);
if ~isempty(errMsg)
    utils.error('model', ...
        [utils.errorparsing(This),errMsg],errList{:});
end

% Create placeholders for non-linearised equations.
This.eqtnN = cell(size(This.eqtn));
This.eqtnN(:) = {''};

% Vectorise operators in full equations; this is needed in numeric
% differentiation.
This.eqtnF = strfun.vectorise(This.eqtnF);


% Nested functions.


%**************************************************************************


    function doChkTimeSsref()
        % Check for { in full and steady-state equations.
        inx = ~cellfun(@isempty,strfind(This.eqtnF,'{')) ...
            | ~cellfun(@isempty,strfind(This.eqtnS,'{'));
        if any(inx)
            utils.error('model',[utils.errorparsing(This), ...
                'Misplaced or invalid time subscript ', ...
                'in this equation: ''%s'''], ...
                This.eqtn{inx});
        end
        % Check for & and $ in full and steady-state equations.
        inx = ~cellfun(@isempty,strfind(This.eqtnF,'&')) ...
            | ~cellfun(@isempty,strfind(This.eqtnS,'&'));
        if any(inx)
            utils.error('model',[utils.errorparsing(This), ...
                'Misplaced or invalid steady-state reference ', ...
                'in this equation: ''%s'''], ...
                This.eqtn{inx});
        end
    end


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
        
    end % doDeclareParameters()


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
        
    end % doChkStdcorrNames()


%**************************************************************************

    
    function doChkUndeclared()
        % Undeclared names have not been substituted for by the name codes, except
        % std and corr names in dynamic links (std and corr names cannot be used in
        % other types of equations). Undeclared names in dynamic links will be
        % caught in `mychksyntax`. Distinguish variable names from function names
        % (func names are immediately followed by an opening bracket).
        % Unfortunately, `regexp` interprets high char codes as \w, so we need to
        % explicitly type the ranges.
        
        list = regexp(This.eqtnF(This.eqtntype < 4), ...
            '\<[a-zA-Z]\w*\>(?![\(\.])','match');
        
        if isempty([list{:}])
            return
        end
        
        if isempty(setdiff(unique([list{:}]),'ttrend'))
            return
        end
        
        undeclared = {};
        stdcorr = {};
        
        isEmptyList = cellfun(@isempty,list);
        for iiEqtn = find(~isEmptyList)
            
            iiList = unique(list{iiEqtn});
            iiList(strcmp(iiList,'ttrend')) = [];
            if isempty(iiList)
                continue
            end
            
            for jj = 1 : length(iiList)
                if strncmp(iiList{jj},'std_',4) ...
                        || strncmp(iiList{jj},'corr_',5)
                    stdcorr{end+1} = iiList{jj}; %#ok<AGROW>
                    stdcorr{end+1} = This.eqtn{iiEqtn}; %#ok<AGROW>
                else
                    undeclared{end+1} = iiList{jj}; %#ok<AGROW>
                    undeclared{end+1} = This.eqtn{iiEqtn}; %#ok<AGROW>
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
    end % doChkUndeclared()


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
    end % doChkSstateRef()


%**************************************************************************
    
    
    function doLossPlaceHolders()
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
        
    end % doLossPlaceHolders()


%**************************************************************************
    
    
    function doChkEmptyEqtn()
        % dochkemptyeqtn  Check for empty full equations.
        emptyInx = cellfun(@isempty,This.eqtnF);
        if any(emptyInx)
            utils.error('model',[utils.errorparsing(This), ...
                'This equation is empty: ''%s''.'], ...
                This.eqtn{emptyInx});
        end
    end % doChkEmptyeEtn()


end


% Subfunctions.


%**************************************************************************


function [Eqtn,EqtnF,EqtnS,EqtnLabel,EqtnAlias, ...
    EqtnNonlin,IsLoss,MultipleLoss] = xxReadEqtns(S)
% xxReadEqtns  Read measurement or transition equations.

Eqtn = cell(1,0);
EqtnLabel = cell(1,0);
EqtnAlias = cell(1,0);
EqtnF = cell(1,0);
EqtnS = cell(1,0);
EqtnNonlin = false(1,0);
IsLoss = false;
MultipleLoss = false;

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
        sign = '+';
        if any(S.eqtnrhs{iEq}(1) == '+-')
            sign = '';
        end
        EqtnF{iEq} = ['-(',S.eqtnlhs{iEq},')',sign,S.eqtnrhs{iEq}];
    else
        EqtnF{iEq} = S.eqtnrhs{iEq};
    end
    if ~isempty(S.sstaterhs{iEq})
        if ~isempty(S.sstatelhs{iEq})
            sign = '+';
            if any(S.sstaterhs{iEq}(1) == '+-')
                sign = '';
            end
            EqtnS{iEq} = ['-(',S.sstatelhs{iEq},')',sign,S.sstaterhs{iEq}];
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
            IsLoss = true;
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
            %{
            % Get the discount factor from inside of the min(...) brackets.
            [close,LossFuncDisc] = strfun.matchbrk(S.eqtnrhs{end},4);
            % Remove the min operator.
            S.eqtnrhs{end} = S.eqtnrhs{end}(close+1:end);
            %}
        elseif sum(lossInx) > 1
            MultipleLoss = true;
        end
    end % doLossFunc()

end % xxReadEqtns()


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

end % xxReadDtrends()


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

end % xxReadLinks()


%**************************************************************************


function [This,Invalid,Nonunique] = xxReadAutoexogenise(This,S)

% `This.Autoexogenise` is reset to NaNs within `myautoexogenise`.
[This,invalid,Nonunique] = myautoexogenise(This,S.eqtnlhs,S.eqtnrhs);
Invalid = S.eqtn(invalid);

end % xxReadautoExogenise()


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

end % xxChkStructure()
