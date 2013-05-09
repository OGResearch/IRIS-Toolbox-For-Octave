function [xOpt,fval,exitflag,output,population,scores,LAMBDA] = ...
    pso(fitnessfcn,P0,Aineq,bineq,Aeq,beq,LB,UB,nonlcon,options,varargin)
% Find the minimum of a function using Particle Swarm Optimization. Can be
% called from model.estimate() or optim.pso() using the syntax below. 
%
% Original version:
% S. Chen. Version 20100818.
% Available from http://www.mathworks.com/matlabcentral/fileexchange/25986
% Distributed under BSD license.
%
% Current version:
% Michael K Johnston 20130423
% for inclusion in the IRIS Toolbox
% http://www.iris-toolbox.com
%
% Syntax:
% [xOpt,fval,flag,out,pop,scores,LAMBDA] ...
%     = pso(fitnessfcn,x0,Aineq,bineq,Aeq,beq,LB,UB,nonlcon,options)
% [xOpt,fval,flag,out,pop,scores,LAMBDA] ...
%     = pso(fitnessfcn,x0)
%
% Options is a struct() which is built by IRIS. Pass these options as a
% cell array to estimate(). For example,
%
% [est,pos,C,H,mest,v,~,~,delta,Pdelta] = ...
%     estimate(m,d,starthist:endhist,E, ...
%     'filter=',filteropt,'solver=','pso','optimset=',...
% 	{'PopulationSize',80,'UseParallel=',true});
%
% The following options are available: 
%
% *CognitiveAttraction*: $[0,1]$ Scalar which controls the relative
%     attraction to the best location a particle can remember. Default:
%     |0.5|.
% 
% *ConstrBoundary*: controls the way imposed constraints are handled when
%    violated. Possible values are:
%    |'soft'|: particles are allowed to travel outside the bounds but get bad
%        fitness function (likelihood) values when they do. 
%    |'reflect'|: particle velocity is changed such that when the particle
%        encounters the bound its velocity is changed to
%        effectively make it bounce off of the boundary. This is the
%        default. 
%    |'absorb'|: particles hit the bound and stay at the bound until
%        attracted elsewhere because its velocity is set to zero.
%
% *Display*: can be |'off'| or |'final'| or |'iter'| in order of increasing
%     verbosity. Default is |'iter'| but will only produce output at most
%     |UpdateInterval| seconds (default is 5 seconds).
%
% *FitnessLimit*: algorithm will terminate when a function value this
%     low is encountered. Default: |-Inf|.
%
% *Generations*: positive integer describing the maximum length of
%     swarm evolution. Default: |1000|.
%
% *HybridFcn*: second stage optimization. By default, IRIS will look for
%     the MATLAB Optimization Toolbox and, if it can find it, use |fmincon|
%     for constrained problems and |fminunc| for unconstrained problems. 
%     When specified, |HybridFcn| can be: 
%     (1) |false|: no second stage optimization, just the particle swarm
%     (2) a string or character array referring to |fminunc| or
%         |fmincon|
%     (3) a cell array in which the first argument specifies the function
%         as previously and the second argument contains the options 
%         structure for that function. 
%         (e.g., |{@fmincon,optimset('Display','iter')}|)
%
% *IncludeInitialValue*: by default the initial vector of values is
%     included in the initial population. To turn this off, set this value
%     to |false|. 
%
% *InitialPopulation*: _(number of variables)-by-(population size)_
%     array containing the initial distribution of particles. By default
%     IRIS will create a population containing the initial parameter vector
%     and the rest of the particles will be randomly generated according to
%     PopInitRange. To exclude the initial value from the initial
%     population so that the entire population is randomly generated, set
%     |'IncludeInitialValue=',false|.
%
% *SocialAttraction*: Positive scalar which controls the relative
%     attraction or each particle to the best location they have heard
%     about from other particles. Default: |1.25|.
%
% *PlotFcns*: cell array of function handles to functions which accept
%     (options,state,flag) values as input arguments. The only built-in
%     general-purpose plotting function is |@optim.scoreDiversity|. 
%
% *PopulationSize*: positive integer which determines the number of
%     particles in the swarm. Default: |40|.
%
% *PopInitRange*: _(2)-by-(number of variables)_ array which sets the
%     range over which the initial population will be distributed, or a
%     _(2)-by-(1)_ array with the range for all parameters, or an empty array
%     (default). By default, if |PopInitRange| is not set, IRIS will use the
%     upper and lower bounds if both are finite. If either of the bounds
%     are infinite, IRIS will use |[0;1]| as the range.
%
% *StallGenLimit*: maximum number of swarm iterations which result in
%     no improvement in the fitness function (likelihood) value before the
%     algorithm terminates. Default: |100|.
%
% *TimeLimit*: maximum running time in seconds. Default: |Inf|.
%
% *TolCon*: largest tolerated constraint violation. 
%
% *TolFun*: function tolerance. When the change in the best fitness function
%     value (likelihood) improvement per generation falls below this value the
%     algorithm will terminate. IRIS will set this to |1e-2| if it can find the
%     MATLAB Optimization Toolbox and |HybridFcn| is not |false|.
%     Otherwise the default is |1e-6|. 
%
% *VelocityLimit*: positive scalar which bounds particle intertia
%     from above. Default: |Inf|.
%
% *UpdateInterval*: minimum length of time in seconds which must pass
%     before new command window output will be produced.
%
% *UseParallel*: can be either |'never'| (default) or |'always'|. Uses a
%     |parfor| loop which requires you already have a |matlabpool| open.
%     Overhead is slightly higher for constrained problems than
%     unconstrained problems. 
%
% Perez and Behdinan (2007) demonstrate the following requirement for
% swarm stability:
%    1) 0 < (C1 + C2) < 4
%    2) (C1 + C2)/2 - 1 < C0 < 1
% where C0 = particle inertia
%       C1 = options.SocialAttraction
%       C2 = options.CognitiveAttraction
% If these conditions are satisfied, the system will be guaranteed to
% converge to a stable equilibrium point. However, whether or not this
% point is actually the global minimum cannot be guaranteed, and its
% acceptability as a solution should be verified by the user.
%
% Bibliography
% J Kennedy, RC Eberhart, YH Shi. Swarm Intelligence. Academic Press, 2001.
%
% SM Mikki, AA Kishk. Particle Swarm Optimization: A Physics-Based
% Approach. Morgan & Claypool, 2008.
%
% RE Perez and K Behdinan. "Particle swarm approach for structural
% design optimization." Computers and Structures, Vol. 85:1579-88, 2007.

try
    options; %#ok<VUNUS>
catch %#ok<CTCH>
    options = {};
end

nvars=numel(P0);
[s1,s2]=size(P0);
if s1>s2, P0=P0'; end %make P0 a row vec

% handle case where optim.pso() is not being called by estimateobj.myestimate()
options = passvalopt('optim.pso',options{:});

switch options.Display
    case 'off'
        options.Verbosity=0;
    case 'final'
        options.Verbosity=2;
    otherwise
        % default
        options.Verbosity=3;
end

if options.PopulationSize>=nvars && options.Verbosity>0, fprintf(1,'Warning: population size is lower than the dimension of the problem. Consider increasing.\n'); end

constr=false;
if ~exist('Aineq','var'), Aineq = [] ; else constr=true; end
if ~exist('bineq','var'), bineq = [] ; else constr=true; end
if ~exist('Aeq','var'), Aeq = [] ; else constr=true; end
if ~exist('beq','var'), beq = [] ; else constr=true; end
if ~exist('LB','var'), LB = [] ; else constr=true; end
if ~exist('UB','var'), UB = [] ; else constr=true; end
if ~exist('nonlcon','var'), nonlcon = [] ; else constr=true; end

if isempty(options.PopInitRange)
    options.InitialPopulationUsesBounds=true;
    options.PopInitRange=[0;1];
end
matlab_optimtbx=license('test','optimization_toolbox');
if matlab_optimtbx && isequal(options.HybridFcn,true)
    % Do not automatically adjust function tolerance in hybrid runs.
    % options.TolFun=1e-2;
    options=xxHybridDefaults(options,LB,UB);
else
    %either optimization toolbox cannot be found or options.HybridFcn is
    %already specified
end

% Check for swarm stability
if options.SocialAttraction + options.CognitiveAttraction >= 4, fprintf(1,'Warning: Swarm is unstable and may not converge since the sum of the cognitive and social attraction parameters is greater than or equal to 4. Suggest adjusting options.CognitiveAttraction and/or options.SocialAttraction.\n'); end

% Non-linear constraints aren't fully supported...
if ~isempty(nonlcon) && strcmpi(options.ConstrBoundary,'reflect')
    warning('pso:main:nonlcon','Non-linear constraints don''t have ''reflect'' boundaries implemented yet. Changing options.ConstrBoundary to ''penalize''.')
    options.ConstrBoundary = 'penalize' ;
end

% Is options.PopInitRange reconcilable with LB and UB constraints?
% Resize PopInitRange in case it was given as one range for all dimensions
if size(options.PopInitRange,2) == 1 && nvars > 1
    options.PopInitRange = repmat(options.PopInitRange,1,nvars) ;
end

% use compact space from UB/LB if available
if options.InitialPopulationUsesBounds
    if options.Verbosity>0
        fprintf(1,'No initial population range given, using finite bounds where available.');
    end
    if ~isempty(LB) && ~isempty(UB)
        for ii=1:nvars
            if isfinite(LB(ii)) && isfinite(UB(ii))
                options.PopInitRange(1,ii)=LB(ii);
                options.PopInitRange(2,ii)=UB(ii);
            end
        end
    end
end

% Check initial population with respect to bound constraints
% Is this really desirable? Maybe there are some situations where the user
% specifically does not want a uniform inital population covering all of
% LB and UB?
if ~isempty(LB) || ~isempty(UB)
    options.LinearConstr.type = 'boundconstraints' ;
    if isempty(LB), LB = -inf*ones(1,nvars) ; end
    if isempty(UB), UB =  inf*ones(1,nvars) ; end
    options.PopInitRange = ...
        psocheckpopulationinitrange(options.PopInitRange,LB,UB) ;
end

% Check validity of VelocityLimit
if all(~isfinite(options.VelocityLimit))
    options.VelocityLimit = [] ;
elseif isscalar(options.VelocityLimit)
    options.VelocityLimit = repmat(options.VelocityLimit,1,nvars) ;
elseif ~isempty(length(options.VelocityLimit)) && ...
        ~isequal(length(options.VelocityLimit),nvars)
    error('options.VelocityLimit must be either a positive scalar or a vector of size 1xnvars.')
end % if isscalar
options.VelocityLimit = abs(options.VelocityLimit) ;

% Generate swarm initial state
if numel(options.InitialPopulation)==nvars || options.IncludeInitialValue
    if options.IncludeInitialValue
        options.InitialPopulation=[];
    else
        P0=options.InitialPopulation;
        options.InitialPopulation=[];
    end
    state = psocreationuniform(options,nvars) ;
    state.Population(1,:)=P0; %allow mix of random population and known reasonable starting value
else
    state = psocreationuniform(options,nvars) ;
end

% Check initial population with respect to linear and nonlinear constraints
if ~isempty(Aeq) || ~isempty(Aineq) || ~isempty(nonlcon)
    options.LinearConstr.type = 'linearconstraints' ;
    if ~isempty(nonlcon)
        options.LinearConstr.type = 'nonlinearconstraints' ;
    end
    if strcmpi(options.ConstrBoundary,'reflect')
        options.ConstrBoundary = 'soft' ;
        warning('pso:mainfcn:constraintbounds','Constraint boundary behavior ''reflect'' is not yet supported for linear constraints. Switching boundary behavior to ''soft''.')
    end
    [state,options] = psocheckinitialpopulation(state,Aineq,bineq,Aeq,beq,LB,UB,nonlcon,options) ;
end

% Check constraint type
if isa(options.ConstrBoundary,'function_handle')
    boundcheckfcn = options.ConstrBoundary ;
elseif strcmpi(options.ConstrBoundary,'soft')
    boundcheckfcn = @psoboundssoft ;
elseif strcmpi(options.ConstrBoundary,'penalize')
    boundcheckfcn = @psoboundspenalize ;
    state.Penalty = zeros(options.PopulationSize,1) ;
    state.PreviouslyFeasible = true(options.PopulationSize,1) ;
elseif strcmpi(options.ConstrBoundary,'reflect')
    boundcheckfcn = @psoboundsreflect ;
elseif strcmpi(options.ConstrBoundary,'absorb')
    boundcheckfcn = @psoboundsabsorb ;
end

n = options.PopulationSize ;

% Change suggested by "Ben" from MATLAB Central.
if ~isempty(options.PlotFcns)
    hFig = findobj('Tag', 'PSO Plots', 'Type', 'figure');
    if isempty(hFig)
        state.hfigure = figure(...
            'NumberTitle', 'off', ...
            'Name', 'Particle Swarm Optimization', ...
            'NextPlot', 'replacechildren', ...
            'Tag', 'PSO Plots' );
    else
        state.hfigure = hFig;
        set(0, 'CurrentFigure', state.hfigure);
        clf
    end
    clear hFig
end % if ~isempty

if options.Verbosity > 0, fprintf('\nSwarming...\n\n'), end
exitflag = 0 ; % Default exitflag, for max iterations reached.
flag = 'init' ;

state.fitnessfcn = fitnessfcn ;
state.LastImprovement = 1 ;
state.ParticleInertia = 0.9 ; % Initial inertia
state.OutOfBounds = false(options.PopulationSize,1) ;

% Iterate swarm
averagetime = 0 ;
t0=tic;
if options.Verbosity>0
	fprintf(1,'Number of variables: %g\n',nvars); 
	fprintf(1,'Population size: %g \n',n);
	if constr, fprintf(1,'Boundary method: %s\n',options.ConstrBoundary); end
	fprintf(1,'\n');
end
if options.Verbosity > 2
    fprintf(1,'Iteration     Best F(x)     Stall\n');
    t2=uint64(0);
end
if options.UseParallel && not(constr)
    % use more efficient parallell implementation, don't check bounds, no
    % extra temporary variables, no plotting availability
    
    statePopulation=state.Population;
    for k = 1:options.Generations
        stateScore = inf*ones(n,1) ; % Reset fitness vector
        state.Generation = k ;
        
        % Evaluate fitness
        parfor i = 1:n
            stateScore(i) = feval(fitnessfcn,statePopulation(i,:),varargin{:});
        end
        
        % Update the local bests
        betterindex = stateScore < state.fLocalBests ;
        state.fLocalBests(betterindex) = stateScore(betterindex) ;
        state.xLocalBests(betterindex,:) = ...
            statePopulation(betterindex,:) ;
        
        % Update the global best and its fitness, then check for termination
        [minfitness, minfitnessindex] = min(stateScore) ;
        
        if minfitness < state.fGlobalBest
            state.fGlobalBest(k) = minfitness ;
            state.xGlobalBest = statePopulation(minfitnessindex,:) ;
            state.LastImprovement = k ;
            imprvchk = k > options.StallGenLimit && ...
                (state.fGlobalBest(k - options.StallGenLimit) - ...
                state.fGlobalBest(k)) / (k - options.StallGenLimit) < ...
                options.TolFun ;
            if imprvchk
                exitflag = 1 ;
                flag = 'done' ;
            elseif state.fGlobalBest(k) < options.FitnessLimit
                exitflag = 2 ;
                flag = 'done' ;
            end % if k
        elseif k > 1 % No improvement from last iteration
            state.fGlobalBest(k) = state.fGlobalBest(k-1) ;
        end % if minfitness
        
		
		stall = k - state.LastImprovement ;
        stallchk = stall >= options.StallGenLimit ;
        if stallchk
            % No improvement for StallGenLimit generations
            exitflag = 3 ;
            flag = 'done' ;
        end
        
        if options.Verbosity>2 && toc(t2)>options.UpdateInterval
            t2=tic;
            fprintf(1,'%9.f     %9g     %5.f \n',k,state.fGlobalBest(k),stall);
        end
        
        t1=toc(t0);
        if t1 + averagetime > options.TimeLimit
            exitflag = 5 ;
            flag = 'done' ;
        end
        
        % Update flags, state and plots before updating positions
        if k == 2, flag = 'iter' ; end
        if k == options.Generations
            flag = 'done' ;
            exitflag = 0 ;
        end
        
        if strcmpi(flag,'done')
            break
        end % if strcmpi
        
        % Update the particle velocities and positions
        state = psoiterate(options,state,flag) ;
        averagetime = t1/k ;
    end % for k
    state.Population=statePopulation;
else
    stateScoreTmp=inf*ones(n,1); %can't be larger, won't necessarily use all of it
    for k = 1:options.Generations
        state.Score = inf*ones(n,1) ; % Reset fitness vector
        state.Generation = k ;
        state.OutOfBounds = false(options.PopulationSize,1) ;
        
        % Check bounds before proceeding
        if ~isequal(boundcheckfcn,@psoboundspenalize) && ...
                ~all([isempty([Aineq,bineq]), isempty([Aeq,beq]), ...
                isempty([LB;UB]), isempty(nonlcon)])
            state = boundcheckfcn(state,Aineq,bineq,Aeq,beq,LB,UB,nonlcon,...
                options) ;
        end % if ~isempty
        
        % Evaluate fitness
        if options.UseParallel
            validi=setdiff(1:n,find(state.OutOfBounds));
            nvalid=numel(validi);
            currStatePop=state.Population(validi,:);
            parfor i = 1:nvalid %parfor
                stateScoreTmp(i) = feval(fitnessfcn,currStatePop(i,:),varargin{:}) ;
            end %parfor
            for i = 1:nvalid
                state.Score(validi(i))=stateScoreTmp(i);
            end
        else
            for i = setdiff(1:n,find(state.OutOfBounds))
                % 				state.Score(i) = fitnessfcn(state.Population(i,:)) ;
                state.Score(i) = feval(fitnessfcn,state.Population(i,:),varargin{:});
            end % for i
        end % if strcmpi(options.Parallel,'always')
        
        % Check bounds before proceeding ('penalize' needs special treatment)
        if isequal(boundcheckfcn,@psoboundspenalize) && ...
                ~all([isempty([Aineq,bineq]), isempty([Aeq,beq]), ...
                isempty([LB;UB]), isempty(nonlcon)])
            state = boundcheckfcn(state,Aineq,bineq,Aeq,beq,LB,UB,nonlcon,...
                options) ;
        end % if ~isempty
        
        % Update the local bests
        betterindex = state.Score < state.fLocalBests ;
        state.fLocalBests(betterindex) = state.Score(betterindex) ;
        state.xLocalBests(betterindex,:) = ...
            state.Population(betterindex,:) ;
        
        % Update the global best and its fitness, then check for termination
        [minfitness, minfitnessindex] = min(state.Score) ;
        
        if minfitness < state.fGlobalBest
            state.fGlobalBest(k) = minfitness ;
            state.xGlobalBest = state.Population(minfitnessindex,:) ;
            state.LastImprovement = k ;
            imprvchk = k > options.StallGenLimit && ...
                (state.fGlobalBest(k - options.StallGenLimit) - ...
                state.fGlobalBest(k)) / (k - options.StallGenLimit) < ...
                options.TolFun ;
            if imprvchk
                exitflag = 1 ;
                flag = 'done' ;
            elseif state.fGlobalBest(k) < options.FitnessLimit
                exitflag = 2 ;
                flag = 'done' ;
            end % if k
        elseif k > 1 % No improvement from last iteration
            state.fGlobalBest(k) = state.fGlobalBest(k-1) ;
        end % if minfitness
        
		stall = k - state.LastImprovement ;
        stallchk = stall >= options.StallGenLimit ;
        if stallchk
            % No improvement for StallGenLimit generations
            exitflag = 3 ;
            flag = 'done' ;
        end
        
        t1=toc(t0);
        if t1 + averagetime > options.TimeLimit
            exitflag = 5 ;
            flag = 'done' ;
        end
        
        % Update flags, state and plots before updating positions
        if k == 2, flag = 'iter' ; end
        if k == options.Generations
            flag = 'done' ;
            exitflag = 0 ;
        end
        
        if ~isempty(options.PlotFcns) && ~mod(k,options.PlotInterval)
            % Exit gracefully if user has closed the figure
            if isempty(findobj('Tag','PSO Plots','Type','figure'))
                exitflag = -1 ;
                break
            end % if isempty
            % Find a good size for subplot array
            rows = floor(sqrt(length(options.PlotFcns))) ;
            cols = ceil(length(options.PlotFcns) / rows) ;
            % Cycle through plotting functions
            if strcmpi(flag,'init')
                haxes = zeros(length(options.PlotFcns),1) ;
            end % if strcmpi
            for i = 1:length(options.PlotFcns)
                if strcmpi(flag,'init')
                    haxes(i) = subplot(rows,cols,i,...
                        'Parent',state.hfigure) ;
                    set(gca,'NextPlot','replacechildren')
                else
                    subplot(haxes(i))
                end % if strcmpi
                if iscell(options.PlotFcns)
                    options.PlotFcns{i}(options,state,flag) ;
                else
                    options.PlotFcns(options,state,flag) ;
                end
            end % for i
            drawnow
        end % if ~isempty
        
        if options.Verbosity>2 && toc(t2)>options.UpdateInterval
            t2=tic;
            fprintf(1,'%9.f     %9g     %5.f \n',k,state.fGlobalBest(k),stall);
        end
        
        if strcmpi(flag,'done'), break; end
        
        % Update the particle velocities and positions
        state = psoiterate(options,state,flag) ;
        averagetime = t1/k ;
    end % for k
end %if options.UseParallel && not(constr)
if options.Verbosity>2, fprintf(1,'%9.f     %9g     %5.f \n',k,state.fGlobalBest(k),stall); end

% Assign output variables and generate output
xOpt = state.xGlobalBest ;
fval = state.fGlobalBest(k) ; % Best fitness value
% Final population: (hopefully very close to each other)
population = state.Population ;
scores = state.Score ; % Final scores (NOT local bests)
output.generations = k ; % Number of iterations performed
clear state

if options.Verbosity > 0, psogenerateoutputmessage(options,output,exitflag) ; end

% Check for hybrid function, run if necessary
if ~isempty(options.HybridFcn) && exitflag ~= -1
    if islogical(options.HybridFcn)
        if options.HybridFcn
            [xOpt,fval] = feval(@psorunhybridfcn,fitnessfcn,xOpt,Aineq,bineq,...
                Aeq,beq,LB,UB,nonlcon,options,varargin{:}) ;
        end
    else
        [xOpt,fval] = feval(@psorunhybridfcn,fitnessfcn,xOpt,Aineq,bineq,...
            Aeq,beq,LB,UB,nonlcon,options,varargin{:}) ;
    end
end

% Wrap up
if options.Verbosity > 0
    if exitflag == -1
        fprintf('\nBest point found: %s\n\n',mat2str(xOpt,5))
    else
        fprintf('\nFinal best point: %s\n\n',mat2str(xOpt,5))
    end
end % if options.Verbosity

LAMBDA.lower=(xOpt<=LB);
LAMBDA.upper=(xOpt>=UB);
end










%% Subfunctions
function initrange = psocheckpopulationinitrange(initrange,LB,UB)
% Automatically adjust PopInitRange according to provided LB and UB.

lowerRange = initrange(1,:) ;
upperRange = initrange(2,:) ;

lowerInf = isinf(LB) ;
index = false(size(lowerRange,2),1) ;
index(~lowerInf) = LB(~lowerInf) ~= lowerRange(~lowerInf) ;
lowerRange(index) = LB(index) ;

upperInf = isinf(UB) ;
index = false(size(upperRange,2),1) ;
index(~upperInf) = LB(~upperInf) ~= upperRange(~upperInf) ;
upperRange(index) = UB(index) ;

initrange = [lowerRange; upperRange] ;
end

function [state,flag] = psoiterate(options,state,flag)
% Updates swarm positions and velocities. Called to iterate the swarm from
% the main PSO function. This function can handle binary and double-vector
% "genomes".

% Weightings for inertia, local, and global influence.
C0 = state.ParticleInertia ;
C1 = options.CognitiveAttraction ; % Local (self best point)
C2 = options.SocialAttraction ; % Global (overall best point)
n = size(state.Population,1) ;
nvars = size(state.Population,2) ;

% lowerinertia = (C1 + C2)/2 - 1 ;
lowerinertia = 0.4 ;
upperinertia = max(0.9,lowerinertia) ;

% Random number seed
R1 = rand(n,nvars) ;
R2 = rand(n,nvars) ;

R1(isinf(state.fLocalBests),:) = 0 ;

% Calculate matrix of velocities state.Velocities for entire population
state.Velocities = C0.*state.Velocities + ...
    C1.*R1.*(state.xLocalBests - state.Population) + ...
    C2.*R2.*(repmat(state.xGlobalBest,n,1) - state.Population) ;
state = checkmaxvelocities(state,options) ;
state.Population = state.Population + state.Velocities ;

% Update behavioral parameters: reduced inertial term
state.ParticleInertia = upperinertia - ...
    lowerinertia*(state.Generation-1) / ...
    (options.Generations-1) ;
end

function state = checkmaxvelocities(state,options)
% Checks the particle velocities against options.VelocityLimit

if ~isempty(options.VelocityLimit) && ... % Check max velocities
        any(isfinite(options.VelocityLimit))
    state.Velocities = min(state.Velocities, ...
        repmat(options.VelocityLimit,n,1)) ;
    state.Velocities = max(state.Velocities, ...
        repmat(-options.VelocityLimit,n,1)) ;
end
end

function state = psocreationuniform(options,nvars)
% Generates uniformly distributed swarm based on options.PopInitRange.

n = options.PopulationSize ;
itr = options.Generations ;

[state,nbrtocreate] = psogetinitialpopulation(options,n,nvars) ;

% Initialize particle positions
state.Population(n-nbrtocreate+1:n,:) = ...
    repmat(options.PopInitRange(1,:),nbrtocreate,1) + ...
    repmat((options.PopInitRange(2,:) - options.PopInitRange(1,:)),...
    nbrtocreate,1).*rand(nbrtocreate,nvars) ;

% Initial particle velocities are zero by default (should be already set in
% PSOGETINTIALPOPULATION).

% Initialize the global and local fitness to the worst possible
state.fGlobalBest = ones(itr,1)*inf; % Global best fitness score
state.fLocalBests = ones(n,1)*inf ; % Individual best fitness score

% Initialize global and local best positions
state.xGlobalBest = ones(1,nvars)*inf ;
state.xLocalBests = ones(n,nvars)*inf ;
end

function [state, nbrtocreate] = psogetinitialpopulation(options,n,nvars)
% Gets the initial population (if any) defined by the options structure.
% Common to both PSOCREATIONUNIFORM and PSOCREATIONBINARY

nbrtocreate = n ;
state.Population = zeros(n,nvars) ;
if ~isempty(options.InitialPopulation)
    nbrtocreate = nbrtocreate - size(options.InitialPopulation,1) ;
    state.Population(1:n-nbrtocreate,:) = options.InitialPopulation ;
    if options.Verbosity > 2, disp('Found initial population'), end
end

% Initial particle velocities
state.Velocities = zeros(n,nvars) ;
if ~isempty(options.InitialVelocities)
    state.Velocities(1:size(options.InitialVelocities,1),:) = ...
        options.InitialVelocities ;
    if options.Verbosity > 2, disp('Found initial velocities'), end
end
end

function state = ...
    psoboundssoft(state,Aineq,bineq,Aeq,beq,LB,UB,nonlcon,options)

x = state.Population ;
% v = state.Velocities ;

for i = 1:size(state.Population,1)
    lowindex = [] ; highindex = [] ;
    if ~isempty(LB), lowindex = x(i,:) < LB ; end
    if ~isempty(UB), highindex = x(i,:) > UB ; end
    
    outofbounds = any([lowindex,highindex]) ;
    if ~outofbounds && ~isempty(Aineq) % Check linear inequalities
        outofbounds = any(Aineq*x(i,:)' - bineq > options.TolCon) ;
    end % if ~isempty
    if ~outofbounds && ~isempty(Aeq) % Check linear equalities
        outofbounds = any(abs(Aeq*x(i,:)' - beq) > options.TolCon) ;
    end % if ~isempty
    if ~outofbounds && ~isempty(nonlcon) % Nonlinear constraint check
        [c,ceq] = nonlcon(x(i,:)) ;
        outofbounds = any(c > options.TolCon) ;
        outofbounds = outofbounds || any(abs(ceq) > options.TolCon) ;
    end
    
    if outofbounds
        state.Score(i) = inf ;
    end % if outofbounds
    
    state.OutOfBounds(i) = outofbounds ;
end % for i

state.Population = x ;
% state.Velocities = v ;
end

function state = ...
    psoboundsreflect(state,Aineq,bineq,Aeq,beq,LB,UB,nonlcon,options)

x = state.Population ;
v = state.Velocities ;

for i = 1:size(state.Population,1)
    lowindex = [] ; highindex = [] ;
    if ~isempty(LB), lowindex = x(i,:) < LB ; end
    if ~isempty(UB), highindex = x(i,:) > UB ; end
    
    x(i,lowindex) = LB(lowindex) ;
    x(i,highindex) = UB(highindex) ;
    v(i,lowindex) = -v(i,lowindex) ;
    v(i,highindex) = -v(i,highindex);
end % for i

state.Population = x ;
state.Velocities = v ;
end

function state = ...
    psoboundspenalize(state,Aineq,bineq,Aeq,beq,LB,UB,nonlcon,options)
% This is like "soft" boundaries, except that some kind of penalty value
% must be calculated from the degree of each constraint violation.

x = state.Population ;
% v = state.Velocities ;

state.OutOfBounds = false(size(state.Population,1),1) ;
state.Penalty = zeros(size(state.Population,1),1) ;

nLB = size(LB,2) ;
nUB = nLB + size(UB,2) ;
nineq = nUB + size(Aineq,1) ;
neq = nineq + size(Aeq,1) ;

if ~isempty(nonlcon)
    [ctest,ceqtest] = nonlcon(zeros(1,options.PopulationSize)) ;
    ctest = ctest(:) ; ceqtest = ceqtest(:) ;
    nnonl = neq + size([ctest;ceqtest],1) ;
else
    nnonl = neq ;
end

nconstr = nnonl ;
f = abs(mean(state.Score)) ;
g = zeros(options.PopulationSize,nconstr) ;

for i = 1:options.PopulationSize
    if ~isempty(LB)
        g(i,1:nLB) = max([LB - x(i,:) ;
            zeros(1,size(state.Population,2))]) ;
    end
    
    if ~isempty(UB)
        g(i,nLB+1:nUB) = max([x(i,:) - UB ;
            zeros(1,size(state.Population,2))]) ;
    end
    
    if ~isempty(Aineq) % Check linear inequalities
        g(i,nUB+1:nineq) = max(Aineq*x(i,:)' - bineq,...
            zeros(size(bineq))) ;
    end % if ~isempty
    
    if ~isempty(Aeq) % Check linear equalities
        g(i,nineq+1:neq) = max(abs(Aeq*x(i,:)' - beq),...
            zeros(size(beq))) ;
    end % if ~isempty
    
    if ~isempty(nonlcon) % Nonlinear constraint check
        [c,ceq] = nonlcon(x(i,:)) ;
        g(i,neq+1:nnonl) = ...
            [max(c(:)' - options.TolCon,zeros(size(c(:)'))) , ...
            max(abs(ceq(:)') > options.TolCon,zeros(size(ceq(:)')))] ;
    end
    
    if any(g(i,:)), state.Velocities(i,:) = 0 ; end
end % for i

state.Penalty = calculatepenalties(f,g,options) ;
state.Score = state.Score + state.Penalty ;
state.Population = x ;
% state.Velocities = v ;
end

function penalty = calculatepenalties(f,g,options)

ssg = sum(mean(g,1).^2,2) ;
penalty = zeros(options.PopulationSize,1) ;
if ssg > options.TolCon ;
    k = zeros(1,size(g,2)) ;
    for i = 1:size(g,1)
        for j = 1:size(g,2)
            k(i,j) = f*mean(g(:,j),1)/ssg ;
        end
        penalty(i) = k(i,:)*g(i,:)' ;
    end
end
end

function state = psoboundsabsorb(state,Aineq,bineq,Aeq,beq,LB,UB,...
    nonlcon,options)

x = state.Population ;
v = state.Velocities ;

for i = 1:size(state.Population,1)
    lowindex = [] ; highindex = [] ;
    if ~isempty(LB), lowindex = x(i,:) < LB ; end
    if ~isempty(UB), highindex = x(i,:) > UB ; end
    % Check against bounded constraints
    x(i,lowindex) = LB(lowindex) ;
    x(i,highindex) = UB(highindex) ;
    v(i,lowindex) = 0 ;
    v(i,highindex) = 0 ;
    
    % Linear and nonlinear constraints
    if ~isempty(Aineq) || ~isempty(Aeq) || ~isempty(nonlcon)
        % "Sticky" linear inequality constraints
        if ~isempty(Aineq)
            if max(Aineq*x(i,:)' - bineq) > options.TolCon
                v(i,:) = 0 ;
            end % if Aineq
        end % if ~isempty
        
        % Won't do set velocities to zero for particles outside of
        % equality constraints, or else particles will rarely ever
        % move. This could change if "slippery" bounds are implemented
        % for linear constraints.
        
        % Finally update all particle positions
        if isempty(nonlcon)
            x(i,:) = linprog([],Aineq,bineq,Aeq,beq,LB,UB,...
                x(i,:),state.LinprogOptions) ;
        else % Check nonlinear constraints
            [c,ceq] = nonlcon(state.Population(i,:)) ;
            if any(c > options.TolCon) || ...
                    any(abs(ceq) > options.TolCon)
                v(i,:) = 0 ; % Sticky
                x(i,:) = fmincon(@void,state.Population(i,:),...
                    Aineq,bineq,Aeq,beq,LB,UB,...
                    nonlcon,state.LinprogOptions) ;
            end % if any
        end % if isempty
    end % if ~isempty
end % for i

state.Population = x ;
state.Velocities = v ;

end

function psogenerateoutputmessage(options,output,exitflag)

if exitflag == 0
    fprintf(1,'Reached limit of %g iterations\n',options.Generations) ;
elseif exitflag == 1
    fprintf(1,'Average cumulative change in value of the fitness function over %g generations less than %g and constraint violation less than %g, and constraint violation less than %g, after %g generations.\n', ...
        options.StallGenLimit,options.TolFun,options.TolCon,output.generations) ;
elseif exitflag == 2
    fprintf(1,'Fitness limit %g reached and constraint violation less than %g.\n', ...
        options.FitnessLimit,options.TolCon) ;
elseif exitflag == 3
    fprintf(1,'The value of the fitness function did not improve in the last %g generations and maximum constraint violation is less than %g after %g generations\n',...
		options.StallGenLimit,options.TolCon,output.generations) ;
elseif exitflag == 5
    fprintf(1,'Time limit of %g seconds has been exceeded after %g generations.',...
		options.TimeLimit,output.generations) ;
elseif exitflag == -1
    fprintf(1,'Optimization stopped by user\n') ;
else
    fprintf(1,'Unrecognized exitflag value\n') ;
end % if exitflag

end

function [xOpt,fval] = psorunhybridfcn(fitnessfcn,xOpt,...
    Aineq,bineq,Aeq,beq,LB,UB,nonlcon,options,varargin)
% Calls the hybrid function defined in options.HybridFcn, from PSO.

if iscell(options.HybridFcn)
    if ischar(options.HybridFcn{1})
        HybridFcn = options.HybridFcn{1};
    else
        HybridFcn = char(options.HybridFcn{1}) ;
    end
    hybridOptions = options.HybridFcn{2} ;
else
    if ischar(options.HybridFcn)
        HybridFcn = options.HybridFcn;
    else
        HybridFcn = char(options.HybridFcn) ;
    end
    hybridOptions = optimset('Display',options.Display,...
        'LargeScale','off') ;
    if isfield(hybridOptions,'Algorithm')
        hybridOptions.Algorithm = 'active-set' ;
    end
end

if options.Verbosity > 0
    fprintf(1,'\nBest point before hybrid function: %s',mat2str(xOpt,5));
    fprintf(1,'\n\nTurning over to hybrid function %s...\n',HybridFcn);
end

% Check for constraints
if strcmp(HybridFcn,'fmincon') && ...
        all([isempty([Aineq,bineq]), isempty([Aeq,beq]), ...
        isempty([LB;UB]),isempty(nonlcon)])
    if options.Verbosity>0, fprintf(1,'Warning: fmincon does not accept problems without constraints. Switching to fminunc.\n'); end
    HybridFcn = 'fminunc' ;
elseif strcmp(HybridFcn,'fminunc') && ...
        ~all([isempty([Aineq,bineq]), isempty([Aeq,beq]), ...
        isempty([LB;UB]),isempty(nonlcon)])
    if options.Verbosity>0, fprintf(1,'Warning: fminunc does not accept problems with constraints. Switching to fmincon.\n'); end
    HybridFcn = 'fmincon' ;
end

if strcmp(HybridFcn,'fmincon')
    [xOpt,fval] = fmincon(fitnessfcn,xOpt,Aineq,bineq,...
        Aeq,beq,LB,UB,nonlcon,hybridOptions,varargin{:}) ;
elseif strcmp(HybridFcn,'fminunc')
    [xOpt,fval] = fminunc(fitnessfcn,xOpt,hybridOptions,varargin{:}) ;
else
    warning('pso:hybridfcn:unrecognized','Unrecognized hybrid function. Ignoring for it now.')
end
end

function [state,options,Aineq,bineq,Aeq,beq] = ...
    psocheckinitialpopulation(state,Aineq,bineq,Aeq,beq,LB,UB,nonlcon,...
    options)
% Checks initial population with respect to linear constraints. Requires
% optimization toolbox.

if exist('linprog','file') ~= 2
    msg = sprintf('Could not find a required function in Optimization ') ;
    msg = sprintf('%s Toolbox. Ignoring (non)linear constraints ',msg) ;
    msg = sprintf('%s for initial population distribution and',msg) ;
    warning('pso:linearconstraints:missingtoolbox',...
        '%s setting constraint behavior to ''penalize''.',msg)
    options.ConstrBoundary = 'penalize' ;
    return
end

% Some robustness for older versions of optimset
vv = ver ;
vernos = {vv.Version} ;
if str2double(vernos{strcmpi({vv.Name},'MATLAB')}) < 7.7
    LinprogOptions = optimset('Simplex','off',...
        'LargeScale','off',...
        'Display','off') ;
else
    LinprogOptions = optimset('Simplex','off',...
        'LargeScale','off',...
        'Algorithm','active-set',...
        'Display','off') ;
end

state.OutOfBounds = false(options.PopulationSize,1) ;

hw = waitbar(0,'Finding feasible initial positions...') ;
for i = 1:size(state.Population,1)
    if strcmpi(options.LinearConstr.type,'linearconstraints')
        if (~isempty(Aineq) && any(Aineq*state.Population(i,:)' - bineq > options.TolCon)) ...
                || (~isempty(Aeq) && any(abs(Aeq*state.Population(i,:)' - beq) > ...
                options.TolCon))
            % Reposition the ith particle if it is outside of linear
            % constraint boundaries
            [newpoint,unused,exitflag] = ...
                linprog([],Aineq,bineq,Aeq,beq,LB,UB,...
                state.Population(i,:),...
                LinprogOptions) ;
            clear unused
            if exitflag == -2
                error('Problem is infeasible due to constraints')
            else
                state.Population(i,:) = reshape(newpoint,1,[]) ;
            end % if exitflag
        end
    elseif strcmpi(options.LinearConstr.type,'nonlinearconstraints')
        [c,ceq] = nonlcon(state.Population(i,:)) ;
        lineq = false ;
        if ~isempty(Aineq)
            lineq = Aineq*state.Population(i,:)' - bineq > ...
                    options.TolCon ;
        end
                
        % Check constraint boundary type
        if i==1 && ~isempty(ceq) && strcmpi(options.ConstrBoundary,'soft')
            msg = '''Soft'' boundaries don''t work with nonlinear' ;
            msg = sprintf('%s equality constraints.',msg) ;
            warning('pso:initpop:nonlcon',...
                '%s Changing options.ConstrBoundary to ''penalize''.',...
                msg)
            options.ConstrBoundary = 'penalize' ;
        end
        
        if isempty(ceq) && isempty(Aeq)
            % Keep trying random points within PopInitRange until we
            % find one that satisfies the nonlinear constraints.
            % This method is faster, but it depends on the user setting
            % appropriate values for PopInitRange. It doesn't work with
            % equality constraints, linear or nonlinear. If LB and UB
            % exist, PopInitRange should already have been set to match
            % them.
            while any(c > options.TolCon) || lineq
                state.Population(i,:) = options.PopInitRange(1,:) + ...
                    rand(1,size(options.PopInitRange,2)) .* ...
                    (options.PopInitRange(2,:) - ...
                    options.PopInitRange(1,:)) ;
                c = nonlcon(state.Population(i,:)) ;
                if ~isempty(Aineq)
                    lineq = Aineq*state.Population(i,:)' - bineq > ...
                        options.TolCon ;
                end
            end % while any
        elseif any(c > options.TolCon) || any(abs(ceq) > options.TolCon)
            % Random point rejection is much faster, and produces
            % a more uniform distribution of points within the bounded
            % region. However, using fmincon to find acceptable points will
            % allow simultaneous compliance with linear and boundary
            % constraints, as well as dealing well with nonlinear equality
            % constraints. Appropriate setting of PopInitRange will prevent
            % the initial points from accumulating near the boundaries.
            [newpoint,unused,exitflag] = ...
                fmincon(@void,state.Population(i,:),...
                Aineq,bineq,Aeq,beq,LB,UB,nonlcon,LinprogOptions) ;
            clear unused
            if exitflag == -2
                error('Problem is infeasible due to nonlinear constraints')
            else
                state.Population(i,:) = reshape(newpoint,1,[]) ;
            end % if exitflag
        end % if isempty
    end % if strcmpi
    waitbar(i/options.PopulationSize,hw)
end % for i
if ishandle(hw), close(hw), end
end

function options=xxHybridDefaults(options,LB,UB)
if ~isempty(LB) && ~isempty(UB)
    if all(isinf(LB)) && all(isinf(UB))
		if options.Verbosity>0, fprintf(1,'Optimization Toolbox available for unconstrained problem: setting HybridFcn to fminunc.\n'); end
        options.HybridFcn='fminunc';
    else
        if options.Verbosity>0, fprintf(1,'Optimization Toolbox available for constrained problem: setting HybridFcn to fmincon.\n'); end
        options.HybridFcn='fmincon';
    end
else
    if options.Verbosity>0, fprintf(1,'Optimization Toolbox available for constrained problem: setting HybridFcn to fmincon.\n'); end
    options.HybridFcn='fmincon';
end
end
