classdef VAR < varobj
    % VAR  Vector autoregressions (VAR) objects and functions.
    %
    % VAR objects can be constructed as plain VARs or simple panel VARs (with
    % fixed effect), and estimated without or with prior dummy observations
    % (quasi-bayesian VARs). VAR objects are reduced-form models; they are also
    % the point of departure for identifying structural VARs
    % ([`SVAR`](SVAR/Contents) objects).
    %
    % VAR methods:
    %
    % Constructor
    % ============
    %
    % * [`VAR`](VAR/VAR) - Create new, empty reduced-form VAR object.
    %
    % Getting information about VAR objects
    % ======================================
    %
    % * [`addparam`](VAR/addparam) - Add VAR parameters to a database (struct).
    % * [`comment`](VAR/comment) - Get or set user comments in an IRIS object.
    % * [`companion`](VAR/companion) - Matrices of first-order companion VAR.
    % * [`eig`](VAR/eig) - Eigenvalues of a VAR process.
    % * [`fprintf`](VAR/fprintf) - Write VAR model as formatted model code to text file.
    % * [`get`](VAR/get) - Query VAR object properties.
    % * [`iscompatible`](VAR/iscompatible) - True if two VAR objects can occur together on the LHS and RHS in an assignment.
    % * [`isexplosive`](VAR/isexplosive) - True if any eigenvalue is outside unit circle.
    % * [`ispanel`](VAR/ispanel) - True for panel VAR based objects.
    % * [`isstationary`](VAR/isstationary) - True if all eigenvalues are within unit circle.
    % * [`length`](VAR/length) - Number of alternative parameterisations in VAR object.
    % * [`mean`](VAR/mean) - Mean of VAR process.
    % * [`nfitted`](VAR/nfitted) - Number of data points fitted in VAR estimation.
    % * [`rngcmp`](VAR/rngcmp) - True if two VAR objects have been estimated using the same dates.
    % * [`sprintf`](VAR/sprintf) - Print VAR model as formatted model code.
    % * [`sspace`](VAR/sspace) - Quasi-triangular state-space representation of VAR.
    % * [`userdata`](VAR/userdata) - Get or set user data in an IRIS object.
    %
    % Referencing VAR objects
    % ========================
    %
    % * [`group`](VAR/group) - Retrieve VAR object from panel VAR for specified group of data.
    % * [`subsasgn`](VAR/subsasgn) - Subscripted assignment for VAR objects.
    % * [`subsref`](VAR/subsref) - Subscripted reference for VAR objects.
    %
    % Simulation, forecasting and filtering
    % ======================================
    %
    % * [`ferf`](VAR/ferf) - Forecast error response function.
    % * [`filter`](VAR/filter) - Filter data using a VAR model.
    % * [`forecast`](VAR/forecast) - Unconditional or conditional VAR forecasts.
    % * [`instrument`](VAR/instrument) - Define conditioning instruments in VAR models.
    % * [`resample`](VAR/resample) - Resample from a VAR object.
    % * [`simulate`](VAR/simulate) - Simulate VAR model.
    %
    % Manipulating VARs
    % ==================
    %
    % * [`alter`](VAR/alter) - Expand or reduce the number of alternative parameterisations within a VAR object.
    % * [`backward`](VAR/backward) - Backward VAR process.
    % * [`demean`](VAR/demean) - Remove constant from VAR object.
    % * [`horzcat`](VAR/horzcat) - Combine two compatible VAR objects in one object with multiple parameterisations.
    % * [`integrate`](VAR/integrate) - Integrate VAR process and data associated with it.
    %
    % Stochastic properties
    % ======================
    %
    % * [`acf`](VAR/acf) - Autocovariance and autocorrelation functions for VAR variables.
    % * [`fmse`](VAR/fmse) - Forecast mean square error matrices.
    % * [`vma`](VAR/vma) - Matrices describing the VMA representation of a VAR process.
    % * [`xsf`](VAR/xsf) - Power spectrum and spectral density functions for VAR variables.
    %
    % Estimation, identification, and statistical tests
    % ==================================================
    %
    % * [`estimate`](VAR/estimate) - Estimate a reduced-form VAR or BVAR.
    % * [`infocrit`](VAR/infocrit) - Populate information criteria for a parameterised VAR.
    % * [`lrtest`](VAR/lrtest) - Likelihood ratio test for VAR models.
    % * [`portest`](VAR/portest) - Portmanteau test for autocorrelation in VAR residuals.
    % * [`schur`](VAR/schur) - Compute and store triangular representation of VAR.
    %
    % Getting on-line help on VAR functions
    % ======================================
    %
    %     help VAR
    %     help VAR/function_name
    %
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.
    
    properties
        K = []; % Constant vector.
        G = []; % Coefficients at co-integrating vector in VEC form.
        Sigma = []; % Cov of parameters.
        T = []; % Shur decomposition of the transition matrix.
        U = []; % Schur transformation of the variables.
        aic = []; % Akaike info criterion.
        sbc = []; % Schwartz bayesian criterion.
        Rr = []; % Parameter restrictions.
        nhyper = NaN; % Number of estimated hyperparameters.
        inames = cell(1,0); % Names of conditioning instruments.
        ieqtn = cell(1,0); % Expressions for conditioning instruments.
        Zi = []; % Measurement matrix for conditioning instruments.
    end
    
    methods
        varargout = acf(varargin)
        varargout = backward(varargin)
        varargout = companion(varargin)
        varargout = demean(varargin)
        varargout = eig(varargin)
        varargout = estimate(varargin)
        varargout = ferf(varargin)
        varargout = filter(varargin)
        varargout = fmse(varargin)
        varargout = forecast(varargin)
        varargout = fprintf(varargin)
        varargout = get(varargin)
        varargout = group(varargin)
        varargout = infocrit(varargin)
        varargout = instrument(varargin)
        varargout = integrate(varargin)  
        varargout = iscompatible(varargin)
        varargout = isexplosive(varargin)
        varargout = isstationary(varargin)
        varargout = length(varargin)
        varargout = lrtest(varargin)
        varargout = mean(varargin)
        varargout = portest(varargin)
        varargout = resample(varargin)
        varargout = schur(varargin)
        varargout = simulate(varargin)
        varargout = sprintf(varargin)
        varargout = sspace(varargin)
        varargout = vma(varargin)
        varargout = xsf(varargin)
        varargout = subsref(varargin)
        varargout = subsasgn(varargin)
    end
    
    methods (Hidden)
        varargout = end(varargin)
        varargout = saveobj(varargin)
        varargout = specget(varargin)
        varargout = SVAR(varargin)
        varargout = myresponse(varargin)
        varargout = mysystem(varargin)
    end
    
    methods (Access=protected,Hidden)
        varargout = mycompatible(varargin)
        varargout = myfitted(varargin)
        varargout = myglsqweights(varargin)
        varargout = myisvalidinpdata(varargin)
        varargout = mynalt(varargin)
        varargout = myny(varargin)
        varargout = myprealloc(varargin)
        varargout = myrngcmp(varargin);
        varargout = mystackdata(varargin)
        varargout = mysubsalt(varargin)
        varargout = size(varargin)
        specdisp(varargin)
    end

    methods (Static,Hidden)
        varargout = myglsq(varargin)
        varargout = loadobj(varargin)
        varargout = restrict(varargin)
    end

    methods (Access=protected,Hidden)
        % Methods sealed in extension classes svarobj or varxobj.
        varargout = mybmatrix(varargin)
        varargout = mycovmatrix(varargin)
    end
    
    
    % Constructor.
    methods    
        function This = VAR(varargin)
            % VAR  Create new, empty reduced-form VAR object.
            %
            % Syntax for plain VAR
            % =====================
            %
            %     V = VAR(YNames)
            %
            % Syntax for panel VAR
            % =====================
            %
            %     V = VAR(YNames,GroupNames)
            %
            % Output arguments
            % =================
            %
            % * `V` [ VAR ] - New empty VAR object.
            %
            % * `YNames` [ cellstr | char | function_handle ] - Names of VAR variables.
            %
            % * `GroupNames` [ cellstr | char | function_handle ] - Names of groups of
            % data for panel estimation.
            %
            % Description
            % ============
            %
            % This function creates a new empty VAR object. It is usually followed by
            % the [`estimate`](VAR/estimate) function to estimate the VAR parameters on
            % data.
            %
            % Example
            % ========
            %
            % To estimate a VAR, you first need to create an empty VAR object
            % specifying the variable names, and then run the
            % [VAR/estimate](VAR/estimate) function on it, e.g.
            %
            %     v = VAR({'x','y','z'});
            %     [v,d] = estimate(v,d,range);
            %
            % where the input database `d` ought to contain time series `d.x`, `d.y`,
            % `d.z`.
            
            % -IRIS Toolbox.
            % -Copyright (c) 2007-2013 IRIS Solutions Team.
            
            This = This@varobj(varargin{:});
            if nargin == 0
                return
            elseif nargin == 1
                if isa(varargin{1},'VAR')
                    This = varargin{1};
                    return
                elseif isstruct(varargin{1})
                    % Convert struct to VAR object.
                    list = properties(This);
                    for i = 1 : length(list)
                        try %#ok<TRYNC>
                            This.(list{i}) = varargin{1}.(list{i});
                        end
                    end
                    % Populate triangular representation.
                    if isempty(This.T) || isempty(This.U) || isempty(This.eigval)
                        This = schur(This);
                    end
                    % Populate information criteria.
                    if isempty(This.aic) || isempty(This.sbc)
                        This = infocrit(This);
                    end
                    return
                end
            end

        end
    end
    
end