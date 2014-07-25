function [Opt,This] = mysstateopt(This,Mode,varargin)
% mysstateopt  [Not a public function] Prepare steady-state solver options.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Run user-supplied steady-state solver:
% 'sstate=',@func
if length(varargin) == 1 && isa(varargin{1},'function_handle')
    Opt = varargin{1};
    return
end

% Run user-supplied steady-state solver with extra arguments:
% 'sstate=',{@func,arg2,arg3,...}
if length(varargin) == 1 && iscell(varargin{1}) ...
        && ~isempty(varargin{1}) ...
        && isa(varargin{1}{1},'function_handle')
    Opt = varargin{1};
    return
end

% Do not run steady-state solver:
% 'sstate=',false
if length(varargin) == 1 && isequal(varargin{1},false)
    Opt = false;
    return
end

% Do run steady-state solve with default options:
% 'sstate=',true
if length(varargin) == 1 && isequal(varargin{1},true)
    varargin(1) = [];
end

% `Mode` is either `'verbose'` (direct calls to `model/sstate`) or
% `'silent'`; the mode determines the default values for `'display='` and
% `'warning='`.
Opt = passvalopt(['model.mysstate',Mode],varargin{:});

%--------------------------------------------------------------------------

if This.IsLinear
    
    % Linear sstate solver
    %----------------------
    % No need to process any options for the linear sstate solver.

else

    % Non-linear sstate solver
    %--------------------------
    [Opt,This] = xxBlocks(This,Opt);
    Opt = xxDisplayOpt(This,Opt);
    if false % ##### MOSW
        Opt = xxOptimOpt(This,Opt);
    else
        % Do nothing
    end
    Opt = xxLogOpt(This,Opt);
    
end

end


% Subfunctions...


%**************************************************************************


function Opt = xxDisplayOpt(This,Opt) %#ok<INUSL>
if islogical(Opt.display)
    if Opt.display
        Opt.display = 'iter';
    else
        Opt.display = 'off';
    end
end
end % xxDisplayOpt()


%**************************************************************************


function Opt = xxOptimOpt(This,Opt) %#ok<INUSL>
% Use Levenberg-Marquardt because it can handle underdetermined systems.
oo = Opt.optimset;
if ~isempty(oo)
    oo(1:2:end) = regexprep(oo(1:2:end),'[^\w]','');
end
Opt.optimset = optimset( ...
    'display',Opt.display, ...
    'maxiter',Opt.maxiter, ...
    'maxfunevals',Opt.maxfunevals,  ...
    'tolx',Opt.tolx, ...
    'tolfun',Opt.tolfun, ...
    'algorithm','levenberg-marquardt', ...
    oo{:});
end % xxOptimOpt()


%**************************************************************************


function [Opt,This] = xxBlocks(This,Opt)

% Process fix options first.
fixL = [];
fixG = [];
doFixOpt();

% Swap nametype of exogenised variables and endogenised parameters.
isSwap = ~isempty(Opt.endogenise) || ~isempty(Opt.exogenise);
if isSwap
    nameType = This.nametype;
    This = mysstateswap(This,Opt);
end

% Run BLAZER if it has not been run yet or if user requested
% exogenise/endogenise.
if Opt.blocks
    if isempty(This.NameBlk) || isempty(This.EqtnBlk) || isSwap
        % Need to run or re-run Blazer.
        [nameBlk,eqtnBlk] = blazer(This,false);
        nameBlkL = nameBlk;
        nameBlkG = nameBlk;
        % Update blocks in the current model object only if no swap is
        % requested.
        if ~isSwap
            This.NameBlk = nameBlkL;
            This.EqtnBlk = eqtnBlk;
        end
    else
        % Use blocks from the current model object.
        nameBlkL = This.NameBlk;
        nameBlkG = This.NameBlk;
        eqtnBlk = This.EqtnBlk;
    end
else
    % If `'blocks=' false`, prepare two blocks:
    % # transition equations;
    % # measurement equations.
    nameBlkL = cell(1,2);
    nameBlkG = cell(1,2);
    % All transition equations and variables.
    eqtnBlk = cell(1,2);
    nameBlkL{1} = find(This.nametype == 2);
    nameBlkG{1} = find(This.nametype == 2);
    eqtnBlk{1} = find(This.eqtntype == 2);
    % All measurement equations and variables.
    nameBlkL{2} = find(This.nametype == 1);
    nameBlkG{2} = find(This.nametype == 1);
    eqtnBlk{2} = find(This.eqtntype == 1);
end

% Finalize sstate equations.
isGrowth = Opt.growth;
eqtnS = myfinaleqtns(This,isGrowth);

nBlk = length(nameBlkL);
blkFunc = cell(1,nBlk);
ixAssign = false(1,nBlk);
% Remove variables fixed by the user.
% Prepare function handles to evaluate individual equation blocks.
for ii = 1 : nBlk
    % Exclude fixed levels and growth rates from the list of optimised
    % names.
    nameBlkL{ii} = setdiff(nameBlkL{ii},fixL);
    nameBlkL{ii} = setdiff(nameBlkL{ii},This.Refresh);
    nameBlkG{ii} = setdiff(nameBlkG{ii},fixG);
    nameBlkG{ii} = setdiff(nameBlkG{ii},This.Refresh);
    if isempty(nameBlkL{ii}) && isempty(nameBlkG{ii})
        continue
    end
    nameLPos = nameBlkL{ii};
    nameGPos = nameBlkG{ii};
    eqtnPos = eqtnBlk{ii};
    iiBlkEqtn = eqtnS(eqtnPos);
    
    % Check if this is a plain, single-equation assignment. If it is an
    % assignment, remove the LHS from `eqtn{1}`, and create a function
    % handle the same way as in other blocks.
    doTestAssign();
        
    % Create a function handle used to evaluate each block of
    % equations or assignments.
    blkFunc{ii} = mosw.str2func(['@(x,dx) [',iiBlkEqtn{:},']']);
end

if isSwap
    This.nametype = nameType;
end

% Index of level and growth variables endogenous in sstate calculation.
endogLInx = false(size(This.name));
endogLInx([nameBlkL{:}]) = true;
endogGInx = false(size(This.name));
endogGInx([nameBlkG{:}]) = true;

% Index of level variables that will be always set to zero.
zeroLInx = false(size(This.name));
zeroLInx(This.nametype == 3) = true;
if Opt.growth
    zeroGInx = false(size(This.name));
    zeroGInx(This.nametype >= 3) = true;
else
    zeroGInx = true(size(This.name));
end

Opt.fixL = fixL;
Opt.fixG = fixG;
Opt.nameBlkL = nameBlkL;
Opt.nameBlkG = nameBlkG;
Opt.eqtnBlk = eqtnBlk;
Opt.ixAssign = ixAssign;
Opt.blkFunc = blkFunc;
Opt.endogLInx = endogLInx;
Opt.endogGInx = endogGInx;
Opt.zeroLInx = zeroLInx;
Opt.zeroGInx = zeroGInx;

    function doFixOpt()
        % Process the fix, fixallbut, fixlevel, fixlevelallbut, fixgrowth,
        % and fixgrowthallbut options. All the user-supply information is
        % combined into fixlevel and fixgrowth.
        canBeFixed = This.nametype <= 2 | This.nametype == 4;
        list = {'fix','fixlevel','fixgrowth'};
        for i = 1 : length(list)
            fix = list{i};
            fixAllBut = [fix,'allbut'];
            
            % Convert charlist to cellstr.
            if ischar(Opt.(fix)) ...
                    && ~isempty(Opt.(fix))
                Opt.(fix) = regexp(Opt.(fix),'\w+','match');
            end
            if ischar(Opt.(fixAllBut)) ...
                    && ~isempty(Opt.(fixAllBut))
                Opt.(fixAllBut) = ...
                    regexp(Opt.(fixAllBut),'\w+','match');
            end
            
            % Convert fixAllBut to fix.
            if ~isempty(Opt.(fixAllBut))
                Opt.(fix) = ...
                    setdiff(This.name(canBeFixed),Opt.(fixAllBut));
            end
            
            if ~isempty(Opt.(fix))
                fixPos = mynameposition(This,Opt.(fix),[1,2,4]);
                ixValid = ~isnan(fixPos);
                if any(~ixValid)
                    utils.error('model:mysstateopt', ...
                        'Cannot fix this name: ''%s''.', ...
                        Opt.(fix){~ixValid});
                end
                Opt.(fix) = fixPos;
            else
                Opt.(fix) = [];
            end
        end
                
        fixL = false(1,length(This.name));
        fixL(Opt.fix) = true;
        fixL(Opt.fixlevel) = true;
        fixG = false(1,length(This.name));
        fixG(This.nametype >= 3) = true;
        if Opt.growth
            fixG(Opt.fix) = true;
            fixG(Opt.fixgrowth) = true;
        else
            fixG(:) = true;
        end
        % Fix optimal policy multipliers. The level and growth of
        % multipliers will be set to zero in the main loop.
        if Opt.zeromultipliers
            fixL = fixL | This.multiplier;
            fixG = fixG | This.multiplier;
        end
        fixL = find(fixL);
        fixG = find(fixG);
    end % doFixOpt()


    function doTestAssign()
        % Test for plain assignment: One equation with one variable solved
        % for on the LHS.
        if length(iiBlkEqtn) > 1 || length(nameLPos) > 1 || length(nameGPos) > 1
            return
        end
        namePos = nameLPos;
        if isempty(namePos)
            namePos = nameGPos;
        end
        xn = sprintf('x(%g)',namePos);
        lhs = sprintf('-(x(%g))',namePos);
        nLhs = length(lhs);
        % The variables that is this block solved for is the only thing on
        % the LHS but does not occur on the RHS.
        ixAssign(ii) = strncmp(iiBlkEqtn{1},lhs,nLhs) ...
            && isempty(strfind(iiBlkEqtn{1}(nLhs+1:end),xn));
        if ixAssign(ii)
            iiBlkEqtn{1}(1:nLhs) = '';
        end
    end % doTestAssing()


end % xxBlocks()


%**************************************************************************


function Opt = xxLogOpt(This,Opt)
% xxLogOpt  Create the list of log-plus and log-minus levels,
% `Opt.IxLogPlus` and `Opt.IxLogMinus`, based on user options `'Unlog='`
% and `'LogMinus='`.

unlogList = Opt.Unlog;
if ischar(unlogList)
    unlogList = regexp(unlogList,'\w+','match');
end
logMinusList = Opt.LogMinus;
if ischar(logMinusList)
    logMinusList = regexp(logMinusList,'\w+','match');
end
conflict = intersect(unlogList,logMinusList);
if ~isempty(conflict)
    utils.error('model:mysstateopt', ...
        'This name is used in both ''Unlog='' and ''LogMinus='': ''%s''.', ...
        conflict{:});
end

% Positions of unlog variables.
unlogPos = mynameposition(This,unlogList,[1,2]);
ixValid = ~isnan(unlogPos);
if any(~ixValid)
    utils.error('model:mysstateopt', ...
        'This name cannot be used in ''Unlog='': ''%s''.', ...
        unlogList{~ixValid});
end

% Positions of log minus variables.
logMinusPos = mynameposition(This,logMinusList,[1,2]);
ixValid = ~isnan(logMinusPos);
if any(~ixValid)
    utils.error('model:mysstateopt', ...
        'This name cannot be used in ''LogMinus='': ''%s''.', ...
        unlogList{~ixValid});
end

% Create lists of log-plus and log-minus levels.
Opt.IxLogPlus = This.IxLog;
Opt.IxLogMinus = false(size(This.IxLog));
Opt.IxLogMinus(logMinusPos) = true;
Opt.IxLogPlus(logMinusPos) = false;
Opt.IxLogPlus(unlogPos) = false;
Opt.IxLogMinus(unlogPos) = false;
end %% xxLogOpt()
