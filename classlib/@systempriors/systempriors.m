classdef systempriors < userdataobj
    % systempriors  System priors.
    %
    % System priors are priors imposed on the system properties of the model as
    % whole, such as shock response functions, frequency response functions,
    % correlations, or spectral densities; moreover, systempriors objects also
    % allow for priors on combinations of parameters. The system priors can be
    % combined with priors on individual parameters.
    %
    % Systempriors methods:
    %
    % Constructor
    % ============
    %
    % * [`systempriors`](systempriors/systempriors) - Create new system priors.
    %
    % Setting up priors
    % ==================
    %
    % * [`prior`](systempriors/prior) - Create prior for a system property.
    %
    % Getting information about system priors
    % ========================================
    %
    % * [`detail`](systempriors/detail) - Display details of system priors.
    % * [`isempty`](systempriors/isempty) - True if the system priors object is empty.
    % * [`length`](systempriors/length) - Number or priors imposed in system priors object.
    %
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.
    
    properties
        eval = cell(1,0);
        priorFunc = cell(1,0);
        lowerBound = zeros(1,0);
        upperBound = zeros(1,0);
        userString = cell(1,0);
        yVec = cell(1,0);
        xVec = cell(1,0);
        eVec = cell(1,0);
        name = cell(1,0);
        eList = cell(1,0);
        systemFunc = struct();
        shockSize = zeros(1,0);
    end % properties.

    methods
        varargout = detail(varargin)
        varargout = disp(varargin)
        varargout = prior(varargin)
        varargout = isempty(varargin)
        varargout = length(varargin)        
    end % methods.
    
    methods (Access=protected,Hidden)
        varargout = mydefinesystemfunc(varargin)
    end % methods.
    
    methods
        function This = systempriors(varargin)
            % systempriors  Create new system priors.
            %
            % Syntax
            % =======
            %
            %     S = systempriors(M)
            %
            % Input arguments
            % ================
            %
            % * `M` [ model ] - Model object on whose system properties the priors will
            % be imposed.
            %
            % Output arguments
            % =================
            %
            % * `S` [ systempriors ] - New, empty system priors object.
            %
            % Description
            % ============
            %
            % Example
            % ========
            
            % -IRIS Toolbox.
            % -Copyright (c) 2007-2013 IRIS Solutions Team.

            %--------------------------------------------------------------------------
            
            if isempty(varargin)
                return
            end
            
            if length(varargin) == 1 ...
                    && isa(varargin{1},'systempriors')
                This = varargin{1};
                return
            end
            
            if length(varargin) == 1 ...
                    && isa(varargin{1},'model')
                m = varargin{1};
                This.yVec = specget(m,'yvector');
                This.xVec = specget(m,'xvector');
                This.eVec = specget(m,'evector');
                This.name = specget(m,'name');
                ne = length(This.eVec);
                if islinear(m)
                    This.shockSize = ones(1,ne);
                else
                    This.shockSize = 0.01*ones(1,ne);
                end
                This = mydefinesystemfunc(This);
            end
            
        end % systempriors().
        
    end % methods.

end % classdef.
