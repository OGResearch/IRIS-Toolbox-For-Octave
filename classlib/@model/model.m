classdef model < modelobj & estimateobj
    % model  Model objects and functions.
    %
    % Model objects are created by loading a [model file](modellang/Contents).
    % Once a model object exists, you can use model functions and standard
    % Matlab functions to write your own m-files to perform the desired tasks,
    % such calibrate or estimate the model, find its steady state, solve and
    % simulate it, produce forecasts, analyse its properties, and so on.
    %
    % Model methods:
    %
    % Constructor
    % ============
    %
    % * [`model`](model/model) - Create new model object based on model file.
    %
    % Getting information about models
    % =================================
    %
    % * [`addparam`](model/addparam) - Add model parameters to a database (struct).
    % * [`autocaption`](model/autocaption) - Create captions for graphs of model variables or parameters.
    % * [`autoexogenise`](model/autoexogenise) - Get or set variable/shock pairs for use in autoexogenised simulation plans.
    % * [`comment`](model/comment) - Get or set user comments in an IRIS object.
    % * [`eig`](model/eig) - Eigenvalues of the model transition matrix.
    % * [`findeqtn`](model/findeqtn) - Find equations by the labels.
    % * [`findname`](model/findname) - Find names of variables, shocks, or parameters by their descriptors.
    % * [`get`](model/get) - Query model object properties.
    % * [`iscompatible`](model/iscompatible) - True if two models can occur together on the LHS and RHS in an assignment.
    % * [`islinear`](model/islinear) - True for models declared as linear.
    % * [`islog`](model/islog) - True for log-linearised variables.
    % * [`isnan`](model/isnan) - Check for NaNs in model object.
    % * [`isname`](model/isname) - True for valid names of variables, parameters, or shocks in model object.
    % * [`issolved`](model/issolved) - True if a model solution exists.
    % * [`isstationary`](model/isstationary) - True if model or specified combination of variables is stationary.
    % * [`length`](model/length) - Number of alternative parameterisations.
    % * [`omega`](model/omega) - Get or set the covariance matrix of shocks.
    % * [`sspace`](model/sspace) - State-space matrices describing the model solution.
    % * [`system`](model/system) - System matrices before model is solved.
    % * [`userdata`](model/userdata) - Get or set user data in an IRIS object.
    %
    % Referencing model objects
    % ==========================
    %
    % * [`subsasgn`](model/subsasgn) - Subscripted assignment for model and systemfit objects.
    % * [`subsref`](model/subsref) - Subscripted reference for model and systemfit objects.
    %
    % Changing model objects
    % =======================
    %
    % * [`alter`](model/alter) - Expand or reduce number of alternative parameterisations.
    % * [`assign`](model/assign) - Assign parameters, steady states, std deviations or cross-correlations.
    % * [`export`](model/export) - Save carry-around files on the disk.
    % * [`horzcat`](model/horzcat) - Combine two compatible model objects in one object with multiple parameterisations.
    % * [`refresh`](model/refresh) - Refresh dynamic links.
    % * [`reset`](model/reset) - Reset specific values within model object.
    % * [`stdscale`](model/stdscale) - Re-scale all std deviations by the same factor.
    % * [`set`](model/set) - Change modifiable model object property.
    % * [`single`](model/single) - Convert solution matrices to single precision.
    %
    % Steady state
    % =============
    %
    % * [`chksstate`](model/chksstate) - Check if equations hold for currently assigned steady0state values.
    % * [`sstate`](model/sstate) - Compute steady state or balance-growth path of the model.
    % * [`sstatefile`](model/sstatefile) - Create a steady-state file based on the model object's steady-state equations.
    %
    % Solution, simulation and forecasting
    % =====================================
    %
    % * [`diffsrf`](model/diffsrf) - Differentiate shock response functions w.r.t. specified parameters.
    % * [`expand`](model/expand) - Compute forward expansion of model solution for anticipated shocks.
    % * [`jforecast`](model/jforecast) - Forecast with judgmental adjustments (conditional forecasts).
    % * [`icrf`](model/icrf) - Initial-condition response functions.
    % * [`lhsmrhs`](model/lhsmrhs) - Evaluate the discrepancy between the LHS and RHS for each model equation and given data.
    % * [`resample`](model/resample) - Resample from the model implied distribution.
    % * [`reporting`](model/reporting) - Run reporting equations.
    % * [`shockplot`](model/shockplot) - Short-cut for running and plotting plain shock simulation.
    % * [`simulate`](model/simulate) - Simulate model.
    % * [`solve`](model/solve) - Calculate first-order accurate solution of the model.
    % * [`srf`](model/srf) - Shock response functions.
    %
    % Model data
    % ===========
    %
    % * [`data4lhsmrhs`](model/data4lhsmrhs) - Prepare data array for running `lhsmrhs`.
    % * [`emptydb`](model/emptydb) - Create model-specific database with variables, shocks, and parameters.
    % * [`sstatedb`](model/sstatedb) - Create model-specific steady-state or balanced-growth-path database.
    % * [`zerodb`](model/zerodb) - Create model-specific zero-deviation database.
    %
    % Stochastic properties
    % ======================
    %
    % * [`acf`](model/acf) - Autocovariance and autocorrelation functions for model variables.
    % * [`ifrf`](model/ifrf) - Frequency response function to shocks.
    % * [`fevd`](model/fevd) - Forecast error variance decomposition for model variables.
    % * [`ffrf`](model/ffrf) - Filter frequency response function of transition variables to measurement variables.
    % * [`fmse`](model/fmse) - Forecast mean square error matrices.
    % * [`vma`](model/vma) - Vector moving average representation of the model.
    % * [`xsf`](model/xsf) - Power spectrum and spectral density of model variables.
    %
    % Identification, estimation and filtering
    % =========================================
    %
    % * [`bn`](model/bn) - Beveridge-Nelson trends.
    % * [`diffloglik`](model/diffloglik) - Approximate gradient and hessian of log-likelihood function.
    % * [`estimate`](model/estimate) - Estimate model parameters by optimising selected objective function.
    % * [`evalsystempriors`](model/evalsystempriors) - Evaluate minus log of system prior density.
    % * [`filter`](model/filter) - Kalman smoother and estimator of out-of-likelihood parameters.
    % * [`fisher`](model/fisher) - Approximate Fisher information matrix in frequency domain.
    % * [`lognormal`](model/lognormal) - Characteristics of log-normal distributions returned by filter of forecast.
    % * [`loglik`](model/loglik) - Evaluate minus the log-likelihood function in time or frequency domain.
    % * [`neighbourhood`](model/neighbourhood) - Evaluate the local behaviour of the objective function around the estimated parameter values.
    % * [`regress`](model/regress) - Centred population regression for selected model variables.
    % * [`VAR`](model/VAR) - Population VAR for selected model variables.
    %
    % Getting on-line help on model functions
    % ========================================
    %
    %     help model
    %     help model/function_name
    %
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.
    
    properties (GetAccess=public,SetAccess=protected,Hidden)
        % Name of the original model file.
        %fname = '';
        % Carry-on packages.
        %Export = '';
        % Linear or non-linear model.
        % linear = false;
        % List of functions with user derivatives.
        userdifflist = cell(1,0);
        % Vector [1-by-nname] of positions of shocks assigned to variables for
        % `autoexogenise`.
        Autoexogenise = nan(1,0);
        % Unit-root tolerance.
        Tolerance = NaN;
        % Names of variables, shocks, and parameters.
        % name = {};
        % Name type: 1=measurement variable, 2=transition variable, 3=shock, 4=parameter.
        % nametype = [];
        % Annotations for variables, shocks, and parameters.
        % namelabel = cell(1,0);
        % Linearised or log-linearised variable.
        % log = [];
        % List of equations in user form.
        % eqtn = cell(1,0);
        % Equation type: 1=measurement, 2=transition, 3=deterministic trend, 4=dynamic link.
        % eqtntype = zeros(1,0);
        % Equation labels.
        % eqtnlabel = cell(1,0);
        % Anonymous function handles to streamlined full dynamic equations.
        eqtnF = cell(1,0);
        % Anonymous function handles to streamlined steady-state equations.
        eqtnS = cell(1,0);
        % A 1-by-nEqtn logical index of equations marked as non-linear.
        nonlin = false(1,0);
        % Block-recursive structure for variable names.
        nameblk = cell(1,0);
        % Block recursive structure for steady-state equations.
        eqtnblk = cell(1,0);
        % Steady-state and parameter values.
        % Assign = [];
        % Steady-state and parameter values used to compute last Taylor expansion.
        Assign0 = nan(1,0);
        % Std deviations and cross-correlations of shocks.
        % stdcorr = nan(1,0);
        % Anonymous function handles to derivatives.
        deqtnF = cell(1,0);
        % Function handles to constant terms in linear models.
        ceqtnF = cell(1,0);
        % Struct describing reporting equations.
        outside = struct();
        % Order of execution of dynamic links.
        Refresh = zeros(1,0);
        % Logical arrays with occurences of variables, shocks and parameters in full dynamic equations.
        occur = sparse(false(0));
        % Logical arrays with occurences of variables, shocks and parameters in steady-state equations.
        occurS = sparse(false(0));
        % Location of t=0 page in `occur`.
        tzero = NaN;
        % Vectors of measurement variables, transition variables, and shocks in columns of unsolved sysmtem matrices.
        systemid = { ...
            cell(1,0), ...
            cell(1,0), ...
            cell(1,0), ...
            };
        % Indices of derivatives used when lining up system matrices.
        %metaderiv = struct();
        % Positions in system matrices corresponding to `metaderiv`.
        %metasystem = struct();
        % Identities added to system matrices.
        %systemident = struct();
        % Indices of non-predetermined variables that duplicate identical predetermined variables.
        %metadelete = false(1,0);
        % Derivatives to system matrices.
        d2s = struct();
        % Last Taylor expansion.
        deriv0 = zeros(0);
        % Last system matrices.
        system0 = struct();
        % Model eigenvalues.
        eigval = zeros(1,0);
        % Differentiation step when calculating numerical derivatives.
        epsilon = eps^(1/3);
        % Matrices necessary to generate forward expansion of model solution.
        Expand = {};
        % Model state-space matrices T, R, K, Z, H, D, U, Y.
        solution = {[],[],[],[],[],[],[],[]};
        % Vectors of measurement variables, transition variables, and shocks in rows and columns of state-space matrices.
        solutionid = {[],[],[]};
        % Vectors of variables names with lags, leads and/or logs.
        solutionvector = { ...
            cell(1,0), ...
            cell(1,0), ...
            cell(1,0), ...
            };
        % True for predetermined variables for which initial condition is truly needed.
        icondix = false(1,0);
        % Base year for deterministic trends.
        torigin = 2000;
        % True for multipliers (optimal policy).
        multiplier = false(1,0);
    end
    
    % Transient properties.
    properties(GetAccess=public,SetAccess=protected,Hidden,Transient)
        % Anonymous function handles to equations evaluating the LHS-RHS.
        eqtnN = cell(1,0);
    end
    
    methods
        varargout = acf(varargin)
        varargout = alter(varargin)
        varargout = assign(varargin)
        varargout = autoexogenise(varargin)
        varargout = bn(varargin)
        varargout = chksstate(varargin)
        varargout = data4lhsmrhs(varargin)
        varargout = diffloglik(varargin)
        varargout = diffsrf(varargin)
        varargout = eig(varargin)
        varargout = estimate(varargin)
        varargout = evalsystempriors(varargin)
        varargout = expand(varargin)
        varargout = fevd(varargin)
        varargout = ffrf(varargin)
        varargout = filter(varargin)
        varargout = findeqtn(varargin)
        varargout = fisher(varargin)
        varargout = fmse(varargin)
        varargout = forecast(varargin)
        varargout = fprintf(varargin)
        varargout = get(varargin)
        varargout = horzcat(varargin)
        varargout = icrf(varargin)
        varargout = ifrf(varargin)
        varargout = irf(varargin)
        varargout = iscompatible(varargin)
        varargout = islog(varargin)
        varargout = isnan(varargin)
        varargout = issolved(varargin)
        varargout = isstationary(varargin)
        varargout = jforecast(varargin)
        varargout = lhsmrhs(varargin)
        varargout = loglik(varargin)
        varargout = lognormal(varargin) %#
        varargout = refresh(varargin)
        varargout = reporting(varargin)
        varargout = resample(varargin)
        varargout = set(varargin)
        varargout = shockplot(varargin)
        varargout = simulate(varargin)
        varargout = single(varargin)
        varargout = solve(varargin)
        varargout = sprintf(varargin)
        varargout = srf(varargin)
        varargout = sspace(varargin)
        varargout = sstate(varargin)
        varargout = sstatedb(varargin)
        varargout = sstatefile(varargin)
        varargout = system(varargin)
        varargout = VAR(varargin)
        varargout = vma(varargin)
        varargout = xsf(varargin)
        varargout = zerodb(varargin)
    end
    
    methods (Hidden)
        varargout = myfdlik(varargin)
        varargout = myfindsspacepos(varargin)
        varargout = myget(varargin)
        varargout = mykalman(varargin)
        varargout = myupdatemodel(varargin)
        varargout = chk(varargin)
        varargout = chksolution(varargin)
        varargout = datarequest(varargin)
        varargout = disp(varargin)
        varargout = end(varargin)
        varargout = fieldnames(varargin)
        varargout = getnonlinobj(varargin)
        varargout = objfunc(varargin)
        varargout = isempty(varargin)
        varargout = saveobj(varargin)
        varargout = specget(varargin)
        varargout = tolerance(varargin)
    end
    
    methods (Access=protected,Hidden)
        varargout = myaffectedeqtn(varargin)        
        varargout = myalpha2xb(varargin)
        varargout = myanchors(varargin)
        varargout = myautoexogenise(varargin)
        varargout = myblazer(varargin)
        varargout = mychksstate(varargin)
        varargout = mychksstateopt(varargin)
        varargout = mychksyntax(varargin)
        varargout = myconsteqtn(varargin)
        varargout = myd2s(varargin)
        varargout = myderiv(varargin)
        varargout = mydiffloglik(varargin)
        varargout = mydtrendsrequest(varargin)
        varargout = mydtrends4lik(varargin)
        varargout = myeqtn2afcn(varargin)
        varargout = myfile2model(varargin)
        varargout = myfinaleqtn(varargin)
        varargout = myfind(varargin)
        varargout = myfindoccur(varargin)
        varargout = myforecastswap(varargin)
        varargout = mykalmanregoutp(varargin)
        varargout = mymodel2model(varargin)
        varargout = mynamepattrepl(varargin)
        varargout = mynonlineqtn(varargin)
        varargout = mynunit(varargin)
        varargout = myoccurence(varargin)
        varargout = myoptpolicy(varargin)
        varargout = myparamstruct(varargin)
        varargout = myparse(varargin)
        varargout = mypreploglik(varargin)
        varargout = myprepsimulate(varargin)
        varargout = myrange2ttrend(varargin)
        varargout = myreshape(varargin)
        varargout = myshocktypes(varargin)
        varargout = mysolve(varargin)
        varargout = mysolvefail(varargin)
        varargout = mysourcedb(varargin)
        varargout = mysspace(varargin)
        varargout = mysstatelinear(varargin)
        varargout = mysstatenonlin(varargin)
        varargout = mysstateopt(varargin)
        varargout = mysstateswap(varargin)
        varargout = mystruct2obj(varargin)
        varargout = mysubsalt(varargin)                
        varargout = mysymbdiff(varargin)
        varargout = mysystem(varargin)
        varargout = mytrendarray(varargin)
        varargout = myvector(varargin)
        varargout = outputdbase(varargin)
    end
    
    methods (Static)
        varargout = failed(varargin)
        varargout = i2model(varargin)
    end
    
    methods (Static,Hidden)
        varargout = myexpand(varargin)
        varargout = myfourierdata(varargin)
        varargout = mymse2var(varargin)
        varargout = myoutoflik(varargin)
        varargout = loadobj(varargin)
        varargout = dataformat(varargin)
    end
    
    % Constructor and dependent properties.
    methods
        
        function This = model(varargin)
            % model  Create new model object based on model file.
            %
            % Syntax
            % =======
            %
            %     m = model(fname,...)
            %     m = model(m,...)
            %
            % Input arguments
            % ================
            %
            % * `fname` [ char | cellstr ] - Name(s) of the model file(s) that will
            % loaded and converted to a new model object.
            %
            % * `m` [ model ] - Existing model object that will be rebuilt as if from a
            % model file.
            %
            % Output arguments
            % =================
            %
            % * `m` [ model ] - New model object based on the input model code
            % file or files.
            %
            % Options
            % ========
            %
            % * `'multiple='` [ true | *false* ] - Allow each variable, shock, or
            % parameter name to be declared (and assigned) more than once in the model
            % file.
            %
            % * `'assign='` [ struct | *empty* ] - Assign model parameters and/or steady
            % states from this database at the time the model objects is being created.
            %
            % * `'baseYear='` [ numeric | *2000* ] - Base year for constructing
            % deterministic time trends.
            %
            % * `'comment='` [ char | *empty* ] - Text comment attached to the model
            % object.
            %
            % * `'declareParameters='` [ *`true`* | `false` ] - If `false`, skip
            % parameter declaration in the model file, and determine the list of
            % parameters automatically as names found in equations but not declared.
            %
            % * `'epsilon='` [ numeric | *eps^(1/4)* ] - The minimum relative step size
            % for numerical differentiation.
            %
            % * `'linear='` [ `true` | *`false`* ] - Indicate linear models.
            %
            % * `'removeLeads='` [ `true` | *`false`* ] - Remove all leads from the
            % state-space vector, keep included only current dates and lags.
            %
            % * `'sstateOnly='` [ `true` | *`false`* ] - Read in only the steady-state
            % versions of equations (if available).
            %
            % * `'std='` [ numeric | *1* for linear models | *0.01* for non-linear
            % models ] - Default standard deviation for model shocks.
            %
            % * `'userdata='` [ ... | *empty* ] - Attach user data to the model object.
            %
            % Description
            % ============
            %
            % Loading a model file
            % ---------------------
            %
            % The `model` function can be used to read in a [model
            % file](modellang/Contents) named `fname`, and create a model object `m`
            % based on the model file. You can then work with the model object in your
            % own m-files, using using the IRIS [model functions](model/Contents) and
            % standard Matlab functions.
            %
            % If `fname` is a cell array of more than one filenames then all files are
            % combined together (in order of appearance).
            %
            % Re-building an existing model object
            % -------------------------------------
            %
            % The only instance where you may need to call a model function on an
            % existing model object is to change the `'removeLeads='` option. Of course,
            % you can always achieve the same by loading the original model file.
            %
            % Example 1
            % ==========
            %
            % Read in a model code file named `my.model`, and declare the model as
            % linear:
            %
            %     m = model('my.model','linear',true);
            %
            % Example 2
            % ==========
            %
            % Read in a model code file named `my.model`, declare the model as linear,
            % and assign some of the model parameters:
            %
            %     m = model('my.model','linear=',true,'assign=',P);
            %
            % Note that this is equivalent to
            %
            %     m = model('my.model','linear=',true);
            %     m = assign(m,P);
            %
            % unless some of the parameters passed in to the `model` fuction are needed
            % to evaluate [`if`](modellang/if) or [`!switch`](modellang/switch)
            % expressions.
            
            % -IRIS Toolbox.
            % -Copyright (c) 2007-2013 IRIS Solutions Team.
            
            % Superclass constructors.
            This = This@modelobj();
            This = This@estimateobj();
            
            if nargin == 0
                % Empty model object.
                return
            elseif nargin == 1 && isa(varargin{1},'model')
                % Copy model object.
                This = varargin{1};
            elseif nargin == 1 && isstruct(varargin{1})
                % Convert struct (potentially based on old model object syntax) to model
                % object.
                This = mystruct2obj(This,varargin{1});
            elseif nargin > 0
                if ischar(varargin{1}) || iscellstr(varargin{1})
                    fileName = strtrim(varargin{1});
                    varargin(1) = [];
                    opt = doOptions();
                    [This,a] = myfile2model(This,fileName,opt);
                    This = mymodel2model(This,a,opt);
                elseif isa(varargin{1},'model')
                    This = varargin{1};
                    varargin(1) = [];
                    opt = doOptions();
                    This = mymodel2model(This,opt.assign,opt);
                end
            else
                utils.error('model', ...
                    'Incorrect number or type of input argument(s).');
            end
            
            function Opt = doOptions()
                [Opt,varargin] = passvalopt('model.model',varargin{:});
                if isempty(Opt.tolerance)
                    This.Tolerance(1) = getrealsmall();
                else
                    This.Tolerance(1) = Opt.tolerance(1);
                    utils.warning('model', ...
                        ['You should NEVER reset the eigenvalue tolerance unless you are ', ...
                        'absolutely sure you know what you are doing!']);
                end
                if isempty(varargin)
                    return
                end
                if ~isstruct(Opt.assign)
                    % Default for `'assign='` is an empty array.
                    Opt.assign = struct();
                end
                Opt.assign.sstateOnly = Opt.sstateonly;
                for iArg = 1 : 2 : length(varargin)
                    Opt.assign.(varargin{iArg}) = varargin{iArg+1};
                end
            end % doOptions().
            
        end
        
    end
    
end