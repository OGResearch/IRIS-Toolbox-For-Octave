function [This,Asgn] = myparse(This,P,Opt)
% myparse  [Not a public function] Parse model code.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

ep = utils.errorparsing(This);

% Linear or non-linear model
%----------------------------

% Linear or non-linear model. First, check for the presence of th keyword
% `!linear` in the model code. However, if the user have specified the
% `'linear='` option in the `model` function, use that.
if ~isempty(strfind(P.code,'!linear'))
    P.code = strrep(P.code,'!linear','');
    
    % ##### Mar 2014 OBSOLETE and scheduled for removal.
    utils.warning('obsolete', ...
        ['Using the keyword !linear in model files is obsolete, ', ...
        'and this feature will be removed from a future version of IRIS. ', ...
        'Use the option ''linear='' in the function model() instead.']);

    This.IsLinear = true;
end

% Run the parser
%----------------

the = theparser('model',P);
[S,Asgn] = parse(the,Opt);

nameBlkOrd = blkpos(the,{ ...
    '!measurement_variables', ...
    '!transition_variables', ...
    '!measurement_shocks', ...
    '!transition_shocks', ...
    '!parameters', ...
    '!exogenous_variables'});

if ~Opt.declareparameters
    doDeclareParameters();
end

% Variables, shocks and parameters
%----------------------------------

% Read the individual names of variables, shocks, and parameters.
This.name = [S(nameBlkOrd).name];
This.nametype = [S(nameBlkOrd).nametype];
This.namelabel = [S(nameBlkOrd).namelabel];
This.namealias = [S(nameBlkOrd).namealias];

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
if ~This.IsLinear
    This.EqtnS(end+(1:n)) = eqtnS;
else
    This.EqtnS(end+(1:n)) = {''};
end
This.eqtnlabel(end+(1:n)) = eqtnLabel;
This.eqtnalias(end+(1:n)) = eqtnAlias;
This.eqtntype(end+(1:n)) = 1;
This.nonlin(end+(1:n)) = false;

% Read transition equations; loss function is always moved to the end.
[eqtn,eqtnF,eqtnS,eqtnLabel,eqtnAlias,nonlin,isLoss,multipleLoss] ...
    = xxReadEqtns(S(6));

if multipleLoss
    utils.error('model',[ep, ...
        'Multiple loss functions found in transition equations.']);
end

n = length(eqtn);
This.eqtn(end+(1:n)) = eqtn;
This.eqtnF(end+(1:n)) = eqtnF;
if ~This.IsLinear
    This.EqtnS(end+(1:n)) = eqtnS;
else
    This.EqtnS(end+(1:n)) = {''};
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
    utils.error('model',[ep, ...
        'The LHS variable must be logarithmised in this dtrend equation: ''%s''.'], ...
        logMissing{:});
end

if ~isempty(invalid)
    utils.error('model',[ep, ...
        'Invalid LHS in this dtrend equation: ''%s''.'], ...
        invalid{:});
end

if ~isempty(multipleLoss)
    utils.error('model',[ep, ...
        'Mutliple dtrend equations ', ...
        'for this measurement variable: ''%s''.'], ...
        multipleLoss{:});
end

% Read dynamic links.

[This,invalid] = xxReadLinks(This,S(11));

if ~isempty(invalid)
    utils.error('model',[ep, ...
        'Invalid LHS in this dynamic link: ''%s''.'], ...
        invalid{:});
end

% Read autoexogenise definitions (variable/shock pairs)
%-------------------------------------------------------
s = S( blkpos(the,'!autoexogenise') );
[This,ixValid,multiple] = myautoexogenise(This,s.eqtnlhs,s.eqtnrhs);
if any(~ixValid)
    utils.error('model',[ep, ...
        'Invalid autoexogenise definition: ''%s''.'], ...
        s.eqtn{~ixValid});
end
if ~isempty(multiple)
    utils.warning('model:myautoexogenise',[ep, ...
        'This shock is included in more than one ', ...
        'autoexogenise definitions: ''%s''.'], ...
        multiple{:});
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
if ~This.IsLinear
    This.EqtnS = strrep(This.EqtnS,'!','');
end

% Remove blank spaces.
This.eqtn = regexprep(This.eqtn,{'\s+','".*?"'},{'',''});
This.eqtnF = regexprep(This.eqtnF,'\s+','');
if ~This.IsLinear
    This.EqtnS = regexprep(This.EqtnS,'\s+','');
end

% Make sure all equations end with semicolons.
for iEq = 1 : length(This.eqtn)
    if ~isempty(This.eqtn{iEq}) && This.eqtn{iEq}(end) ~= ';'
        This.eqtn{iEq}(end+1) = ';';
    end
    if ~isempty(This.eqtnF{iEq}) && This.eqtnF{iEq}(end) ~= ';'
        This.eqtnF{iEq}(end+1) = ';';
    end
    if ~isempty(This.EqtnS{iEq}) && This.EqtnS{iEq}(end) ~= ';'
        This.EqtnS{iEq}(end+1) = ';';
    end
end

% Max lag and lead
%------------------

maxT = max([S.maxt]);
minT = min([S.mint]);
if isLoss
    % Anticipate that multipliers will have leads as far as the greatest
    % lag, and lags as far as the greatest lead.
    maxT = maxT - minT;
    minT = minT - maxT;    
end
maxT = maxT + 1;
minT = minT - 1;
tZero = 1 - minT;
This.tzero = tZero;
nt = maxT - minT + 1;

% Replace variables names with codes
%------------------------------------

% Check for sstate references occuring in wrong places. Also replace
% the old syntax & with $.
doChkSstateRef();

This.occur = false(nEqtn,nName*nt);
This.occurS = false(nEqtn,nName);

[namePatt,nameReplF,nameReplS] = mynamepattrepl(This);

% Steady-state equations
%------------------------

if ~This.IsLinear
    % If no steady-state version exists, copy the full equation.
    isEmptySstate = cellfun(@isempty,This.EqtnS) & This.eqtntype <= 2;
    This.EqtnS(isEmptySstate) = This.eqtnF(isEmptySstate);
    This.EqtnS(This.eqtntype > 2) = {''};
    if isLoss
        % Do not copy the loss function to steady state equations.
        This.EqtnS{lossPos} = '';
    end
    
    This.EqtnS = regexprep(This.EqtnS,namePatt,nameReplS);
    
    % Remove steady-state references from steady-state equations; they are
    % treated as the respective variables.
    This.EqtnS = strrep(This.EqtnS,'&%','%');
    This.EqtnS = strrep(This.EqtnS,'&#','#');
    
    % Replace
    % * `%(!10){@-2}` with `(%(!10)-2*d%(!10))`;
    % * `#(!10){@+2}` with `(#(!10)*d#(!10)^2)`;
    % * `#(!10){@-2}` with `(#(!10)/d#(!10)^2)`;
    This.EqtnS = regexprep(This.EqtnS, ...
        '%\(!(\d+)\)\{@([\+\-]\d+)\}', ...
        '(%(!$1)$2*d%(!$1))');
    This.EqtnS = regexprep(This.EqtnS, ...
        '#\(!(\d+)\)\{@\+?(\d+)\}', ...
        '(#(!$1)*d#(!$1)^$2)');
    This.EqtnS = regexprep(This.EqtnS, ...
        '#\(!(\d+)\)\{@\-(\d+)\}', ...
        '(#(!$1)/d#(!$1)^$2)');
    
    % Replace ?(!10) with g(10).
    This.EqtnS = strrep(This.EqtnS,'?(!','g(');
    
else
    This.EqtnS(:) = {''};
end

% Full equations
%----------------

This.eqtnF = regexprep(This.eqtnF,namePatt,nameReplF);

% Replace %(:,!10,@){@+2} with %(:,!10,@+2) to complete time subscripts.
This.eqtnF = strrep(This.eqtnF,'@){@','@');
This.eqtnF = strrep(This.eqtnF,'}',')');

% Try to catch undeclared names in all equations except dynamic links at
% this point; all valid names have been substituted for by %(...) and
% ?(...). Do not do it in dynamic links because the links can contain std
% and corr names which have not been substituted for.
doChkUndeclared();

% Replace control codes in steady-state equations.
This.EqtnS = strrep(This.EqtnS,'%','x');
This.EqtnS = strrep(This.EqtnS,'#','x');
This.EqtnS = strrep(This.EqtnS,'!','');

% Replace control codes in full equations.
% * Exogenous variables `?(!15,:)` -> `g(!15,:)`.
% * Variables, parameters, shocks `%(:,!15,@+5)` -> `x(:,!15,@+5)`.
% * Steady-state references `&x(:,!15,@+5)` -> `L(:,!15,@+5)`.
% * Time subscripts `@+5` -> `t+5`.
% * Remove `!` from name positions.
This.eqtnF = strrep(This.eqtnF,'?(!','g(');
This.eqtnF = strrep(This.eqtnF,'%','x');
This.eqtnF = strrep(This.eqtnF,'&x','L');
This.eqtnF = strrep(This.eqtnF,'@','t');
This.eqtnF = strrep(This.eqtnF,'!','');

% Check for orphan { and & after we have substituted for the valid
% references.
doChkTimeSsref();

if isLoss
    % Find the closing bracket in min(...), retrieve the discount factor, and
    % remove the whole term from the loss function equation.
    [endDisc,lossDisc] = strfun.matchbrk(This.eqtnF{lossPos},4);
    if isempty(endDisc)
        utils.error('model:myparse',[ep, ...
            'Syntax error in the loss function.']);
    end
    if isempty(lossDisc)
        utils.error('model',[ep, ...
            'Loss function discount factor is empty.']);
    end    
end

% Find the occurences of variable, shocks, and parameters in individual
% equations, including the loss function and its discount factor. The
% occurences in the loss function will be replaced later with the
% occurences in the Lagrangian derivatives.
This = myoccurrence(This,Inf); 

if isLoss
    This.eqtnF{lossPos}(1:endDisc) = '';
end

% Check equation syntax before we compute optimal policy but after we
% remove the header min(...) from the loss function equation.
if Opt.chksyntax
    mychksyntax(This);
end

% Check the model structure -- part 1 before the loss function is processed.
[errMsg,errList] = xxChkStructure1(This);
if ~isempty(errMsg)
    utils.error('model',[ep,errMsg],errList{:});
end

if isLoss
    % Create optimal policy equations by adding the derivatives of the
    % Lagrangian wrt to the original transition variables. These `naddeqtn` new
    % equation will be put in place of the loss function and the `naddeqtn-1`
    % empty placeholders.
    [newEqtn,newEqtnF,newEqtnS,NewNonlin] ...
        = myoptpolicy(This,lossPos,lossDisc,Opt.optimal);
    
    % Add the new equations to the model object, and parse them.
    last = find(This.eqtntype == 2,1,'last');
    This.eqtn(lossPos:last) = newEqtn(lossPos:last);
    This.eqtnF(lossPos:last) = newEqtnF(lossPos:last);
    
    if ~This.IsLinear
        % Add sstate equations. Note that we must at least replace the old equation
        % in `lossPos` position (which was the objective function) with the new
        % equation (which is a derivative wrt to the first variables).
        This.EqtnS(lossPos:last) = newEqtnS(lossPos:last);
        % Update the nonlinear equation flags.
        This.nonlin(lossPos:last) = NewNonlin(lossPos:last);
    end
    
    % Update occurence arrays with new equations.
    This = myoccurrence(This,lossPos:last);
end

% Finishing touches
%-------------------

% Sparse occurence arrays.
This.occur = sparse(This.occur(:,:));
This.occurS = sparse(This.occurS);

% Check the model structure -- part 2 after the loss function is processed.
[errMsg,errList] = xxChkStructure2(This);
if ~isempty(errMsg)
    utils.error('model',[ep,errMsg],errList{:});
end

% Create placeholders for non-linearised equations.
This.eqtnN = cell(size(This.eqtn));
This.eqtnN(:) = {''};

% Vectorise operators in full equations; this is needed in numeric
% differentiation.
This.eqtnF = strfun.vectorise(This.eqtnF);

% Retype shocks.
This.nametype = floor(This.nametype);


% Nested functions...


%**************************************************************************


    function doChkTimeSsref()
        % Check for { in full and steady-state equations.
        inx = ~cellfun(@isempty,strfind(This.eqtnF,'{')) ...
            | ~cellfun(@isempty,strfind(This.EqtnS,'{'));
        if any(inx)
            utils.error('model',[ep, ...
                'Misplaced or invalid time subscript ', ...
                'in this equation: ''%s'''], ...
                This.eqtn{inx});
        end
        % Check for & and $ in full and steady-state equations.
        inx = ~cellfun(@isempty,strfind(This.eqtnF,'&')) ...
            | ~cellfun(@isempty,strfind(This.EqtnS,'&'));
        if any(inx)
            utils.error('model',[ep, ...
                'Misplaced or invalid steady-state reference ', ...
                'in this equation: ''%s'''], ...
                This.eqtn{inx});
        end
    end


%**************************************************************************


    function doDeclareParameters()
        
        % All declared names except parameters.
        pos = blkpos(the,{ ...
            '!measurement_variables', ...
            '!transition_variables', ...
            '!measurement_shocks', ...
            '!transition_shocks', ...
            '!exogenous_variables'});
        declaredNames = [S(pos).name];
        
        % All names occuring in transition and measurement equations.
        pos = blkpos(the,{ ...
            '!measurement_equations', ...
            '!transition_equations'});
        allEqtn = [S(pos).eqtn];
        allEqtn = [allEqtn{:}];
        allNames = regexp(allEqtn,'\<[A-Za-z]\w*\>(?![\(\.])','match');
        allNames = unique(allNames);
        
        % Determine residual names.
        addNames = setdiff(allNames,declaredNames);

        % Re-create the parameter declaration section.
        nAdd = length(addNames);
        pos = blkpos(the,'!parameters');
        S(pos).name = addNames;
        S(pos).nametype = 4*ones(1,nAdd);
        tempCell = cell(1,nAdd);
        tempCell(:) = {''};
        S(pos).namelabel = tempCell;
        S(pos).namealias = tempCell;
        S(pos).namevalue = tempCell;
        S(pos).nameflag = false(1,nAdd);
        
    end % doDeclareParameters()


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
            utils.error('model',[ep, ...
                'Std or corr name ''%s'' cannot be used in ''%s''.'], ...
                stdcorr{:});
        end
        
        % Report non-function names that have not been declared.
        if ~isempty(undeclared)
            utils.error('model',[ep, ...
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
        if This.IsLinear
            if any(inx)
                utils.error('model',[ep, ...
                    'Steady-state references not allowed ', ...
                    'in linear models: ''%s''.'], ...
                    This.eqtn{inx});
            end
            return
        end
        inx = inx | func(This.EqtnS);
        % Not allowed in deterministic trends.
        temp = inx & This.eqtntype == 3;
        if any(temp)
            utils.error('model',[ep, ...
                'Steady-state references not allowed ', ...
                'in dtrends equations: ''%s''.'], ...
                This.eqtn{temp});
        end
        % Not allowed in dynamic links.
        temp = inx & This.eqtntype == 4;
        if any(temp)
            utils.error('model',[ep, ...
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
        % The default name is `Mu_Eq%g` but can be changed through the
        % option `'multiplierName='`.
        newName = cell(1,nAddName-1);
        for ii = 1 : nAddName
            newName{ii} = sprintf(Opt.multipliername,ii);
        end
        [~,inx] = strfun.unique(newName);
        if any(inx)
            utils.error('model:myparse',[ep, ...
                'Name template for optimal policy multipliers ', ...
                'does not produce unique names: ''%s''.'], ....
                Opt.multipliername);
        end
        % Insert the new names between at the beginning of the block of existing
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
        % We will add `nAddEqtn` new transition equations, i.e. the
        % derivatives of the Lagrangian wrt the existing transition
        % variables. At the same time, we will remove the loss function so
        % we need to create only `nAddEqtn-1` placeholders.
        This.eqtn(end+(1:nAddEqtn)) = {''};
        This.eqtnF(end+(1:nAddEqtn)) = {''};
        This.EqtnS(end+(1:nAddEqtn)) = {''};
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
            utils.error('model',[ep, ...
                'This equation is empty: ''%s''.'], ...
                This.eqtn{emptyInx});
        end
    end % doChkEmptyeEtn()


end


% Subfunctions...


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
        % doLossFunc  Find loss function amongst equations; the loss
        % function starts with `min(` or `min#(` and the expression must
        % not have an equal sign, i.e. the LHS must be empty.
        findMin = regexp(S.eqtnrhs,'^min#?\(','once');
        lossInx = ~cellfun(@isempty,findMin) & cellfun(@isempty,S.eqtnlhs);
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
This.EqtnS(end+(1:n)) = {''};
This.eqtnlabel(end+(1:n)) = eqtnlabel;
This.eqtnalias(end+(1:n)) = eqtnalias;
This.eqtntype(end+(1:n)) = 3;
This.nonlin(end+(1:n)) = false;

end % xxReadDtrends()


%**************************************************************************


function [This,Invalid] = xxReadLinks(This,S)

nName = length(This.name);
nEqtn = length(S.eqtn);

valid = false(1,nEqtn);
refresh = nan(1,nEqtn);
inxE = floor(This.nametype) == 3;
for iEq = 1 : nEqtn
    if isempty(S.eqtn{iEq})
        continue
    end
    [assignInx,stdcorrInx] = modelobj.mynameindex( ...
        This.name,This.name(inxE),S.eqtnlhs{iEq});
    %index = strcmp(This.name,S.eqtnlhs{iEq});
    if any(assignInx)
        % The LHS name is a variable, shock, or parameter name.
        valid(iEq) = true;
        refresh(iEq) = find(assignInx);
    elseif any(stdcorrInx)
        % The LHS name is a std or corr name.
        valid(iEq) = true;
        refresh(iEq) = nName + find(stdcorrInx);
    end
end

Invalid = S.eqtn(~valid);
This.eqtn(end+(1:nEqtn)) = S.eqtn;
This.eqtnF(end+(1:nEqtn)) = S.eqtnrhs;
This.EqtnS(end+(1:nEqtn)) = {''};
This.eqtnlabel(end+(1:nEqtn)) = S.eqtnlabel;
This.eqtnalias(end+(1:nEqtn)) = S.eqtnalias;
This.eqtntype(end+(1:nEqtn)) = 4;
This.nonlin(end+(1:nEqtn)) = false;
This.Refresh = refresh;

end % xxReadLinks()


%**************************************************************************


function [ErrMsg,ErrList] = xxChkStructure1(This)

nEqtn = length(This.eqtn);
nName = length(This.name);
tZero = This.tzero;
occurF = This.occur;
if size(occurF,3) == 1
   nt = size(occurF,2) / nName;
   occurF = reshape(full(occurF),[nEqtn,nName,nt]);
end
occurS = This.occurS;

ErrMsg = '';
ErrList = {};

% Lags and leads.
tt = true(1,size(occurF,3));
tt(tZero) = false;

flNameType = floor(This.nametype);

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
aux = any(any(occurF(:,flNameType == 3,tt),3),1);
if any(aux)
    ErrList = This.name(flNameType == 3);
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

% Lags and leads of exogenous variables are capture as misplaced time
% subscripts.

% No lags/leads of exogenous variables.
% check = any(any(occurF(:,This.nametype == 5,tt),3),1);
% if any(check)
%     ErrList = This.name(This.nametype == 4);
%     ErrList = ErrList(check);
%     ErrMsg = 'This exogenous variables occurs with a lag/lead: ''%s''.';
%     return
% end

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

if any(flNameType == 3)
    % Find transition shocks in measurement equations.
    aux = any(occurF(This.eqtntype == 1,This.nametype == 3.2,tZero),1);
    if any(aux)
        ErrList = This.name(This.nametype == 3.2);
        ErrList = ErrList(aux);
        ErrMsg = ['This transition shock occurs ', ...
            'in measurement equation(s): ''%s''.'];
        return
    end
    % Find measurement shocks in transition equations.
    aux = any(occurF(This.eqtntype == 2,This.nametype == 3.1,tZero),1);
    if any(aux)
        ErrList = This.name(This.nametype == 3.1);
        ErrList = ErrList(aux);
        ErrMsg = ['This measurement shock occurs ', ...
            'in transition equation(s): ''%s''.'];
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
    ErrMsg = ['The RHS of this dtrend equation ', ...
        'refers to name(s) ', ...
        'other than parameters or exogenous variables: ''%s''.'];
    return
end

% Exogenous variables only in dtrend equations.
rows = This.eqtntype ~= 3;
cols = This.nametype == 5;
check = any(any(occurF(rows,cols,:),3),2) | any(occurS(rows,cols),2);
if any(check)
    ErrList = This.eqtn(rows);
    ErrList = ErrList(check);
    ErrMsg = ['Exogenous variables allowed only in ', ...
        'dtrend equations: ''%s''.'];
    return
end

end % xxChkStructure1()


%**************************************************************************


function [ErrMsg,ErrList] = xxChkStructure2(This)

nEqtn = length(This.eqtn);
nName = length(This.name);
tZero = This.tzero;
occurF = This.occur;
if size(occurF,3) == 1
   nt = size(occurF,2) / nName;
   occurF = reshape(full(occurF),[nEqtn,nName,nt]);
end

ErrMsg = '';
ErrList = {};

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

end % xxChkStructure2()
