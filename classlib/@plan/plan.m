classdef plan < userdataobj & getsetobj
    % plan  Simulation plans.
    %
    % Simulation plans complement the use of the
    % [`model/simulate`](model/simulate) or
    % [`model/jforecast`](model/jforecast) functions.
    %
    % You need to use a simulation plan object to set up the following types of
    % more complex simulations or forecasts (or a combination of these):
    %
    % # simulations or forecasts with some of the model variables temporarily
    % exogenised;
    %
    % # simulations with some of the non-linear equations solved in an exact
    % non-linear mode;
    %
    % # forecasts conditioned upon some variables;
    %
    % The plan object is passed to the [`model/simulate`](model/simulate) or
    % [`model/jforecast`](model/jforecast) functions through the `'plan='`
    % option.
    %
    % Plan methods:
    %
    % Constructor
    % ============
    %
    % * [`plan`](plan/plan) - Create new, empty simulation plan object.
    %
    % Getting information about simulation plans
    % ===========================================
    %
    % * [`detail`](plan/detail) - Display details of a simulation plan.
    % * [`get`](plan/get) - Query to plan object.
    % * [`nnzcond`](plan/nnzcond) - Number of conditioning data points.
    % * [`nnzendog`](plan/nnzendog) - Number of endogenised data points.
    % * [`nnzexog`](plan/nnzexog) - Number of exogenised data points.
    % * [`nnznonlin`](plan/nnznonlin) - Number of non-linearised data points.
    %
    % Setting up simulation plans
    % ============================
    %
    % * [`autoexogenise`](plan/autoexogenise) - Exogenise variables and automatically endogenise corresponding shocks.
    % * [`condition`](plan/condition) - Condition forecast upon the specified variables at the specified dates.
    % * [`endogenise`](plan/endogenise) - Endogenise shocks or re-endogenise variables at the specified dates.
    % * [`exogenise`](plan/exogenise) - Exogenise variables or re-exogenise shocks at the specified dates.
    % * [`nonlinearise`](plan/nonlinearise) - Select equations for simulation in an exact non-linear mode.
    %
    % Referencing plan objects
    % ==========================
    %
    % * [`subsref`](plan/subsref) - Subscripted reference for plan objects.
    %
    % Getting on-line help on simulation plans
    % =========================================
    %
    %     help plan
    %     help plan/function_name
    %
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2014 IRIS Solutions Team.
    
    properties
        startDate = NaN;
        endDate = NaN;
        xList = {};
        nList = {};
        qList = {};
        cList = {};
        xAnchors = []; % Exogenised.
        nAnchorsReal = []; % Endogenised real.
        nAnchorsImag = []; % Endogenised imag.
        nWeightsReal = []; % Weights for endogenised real.
        nWeightsImag = []; % Weights for endogenised imag.
        cAnchors = []; % Conditioned.
        qAnchors = []; % Non-linearised.
        AutoExogenise = [];
    end
    
    methods
        
        function This = plan(varargin)
            % plan  Create new, empty simulation plan object.
            %
            % Syntax
            % =======
            %
            %     P = plan(M,Range)
            %
            % Input arguments
            % ================
            %
            % * `M` [ model ] - Model object that will be simulated subject to this
            % simulation plan.
            %
            % * `Range` [ numeric ] - Simulation range; this range must exactly
            % correspond to the range on which the model will be simulated.
            %
            % Output arguments
            % =================
            %
            % * `P` [ plan ] - New, empty simulation plan.
            %
            % Description
            % ============
            %
            % You need to use a simulation plan object to set up the following types of
            % more complex simulations or forecats:
            %
            % # simulations or forecasts with some of the model variables temporarily exogenised;
            %
            % # simulations with some of the non-linear equations solved exactly.
            %
            % # forecasts conditioned upon some variables;
            %
            % The plan object is passed to the [simulate](model/simulate) or
            % [`jforecast`](model/jforecast) functions through the option `'plan='`.
            %
            % Example
            % ========
            %
            
            % -IRIS Toolbox.
            % -Copyright (c) 2007-2014 IRIS Solutions Team.
            
            This = This@userdataobj();
            This = This@getsetobj();
            
            if length(varargin) > 1
                
                pp = inputParser();
                pp.addRequired('M',@(x) isa(x,'modelobj'));
                pp.addRequired('Range',@isnumeric);
                pp.parse(varargin{1:2});
                
                % Range.
                This.startDate = varargin{2}(1);
                This.endDate = varargin{2}(end);
                nPer = round(This.endDate - This.startDate + 1);
                % Exogenising.
                This.xList = myget(varargin{1},'canbeexogenised');
                This.xAnchors = false(length(This.xList),nPer);
                % Endogenising.
                This.nList = myget(varargin{1},'canbeendogenised');
                This.nAnchorsReal = false(length(This.nList),nPer);
                This.nAnchorsImag = false(length(This.nList),nPer);
                This.nWeightsReal = zeros(length(This.nList),nPer);
                This.nWeightsImag = zeros(length(This.nList),nPer);
                % Non-linearising.
                This.qList = myget(varargin{1},'canbenonlinearised');
                This.qAnchors = false(length(This.qList),nPer);
                % Conditioning.
                This.cList = This.xList;
                This.cAnchors = This.xAnchors;
                % Autoexogenise.
                This.AutoExogenise = nan(size(This.xList));
                try %#ok<TRYNC>
                    a = autoexogenise(varargin{1});
                    xList = fieldnames(a); %#ok<PROP>
                    nList = struct2cell(a); %#ok<PROP>
                    na = length(xList); %#ok<PROP>
                    for ia = 1 : na
                        xInx = strcmp(This.xList,xList{ia}); %#ok<PROP>
                        nInx = strcmp(This.nList,nList{ia}); %#ok<PROP>
                        This.AutoExogenise(xInx) = find(nInx);
                    end
                end
            end
            
        end
        
        varargout = autoexogenise(varargin)
        varargout = condition(varargin)
        varargout = detail(varargin)
        varargout = exogenise(varargin)
        varargout = endogenise(varargin)
        varargout = isempty(varargin)
        varargout = nnzcond(varargin)
        varargout = nnzendog(varargin)
        varargout = nnzexog(varargin)
        varargout = nnznonlin(varargin)
        varargout = nonlinearise(varargin)
        varargout = subsref(varargin)
        
        varargout = get(varargin)
        varargout = set(varargin)
        
    end
    
    methods (Hidden)
        
        varargout = mydateindex(varargin)
        varargout = disp(varargin)
        
        % Aliasing.
        function varargout = autoexogenize(varargin)
            [varargout{1:nargout}] = autoexogenise(varargin{:});
        end
        
        function varargout = exogenize(varargin)
            [varargout{1:nargout}] = exogenise(varargin{:});
        end
        
        function varargout = endogenize(varargin)
            [varargout{1:nargout}] = endogenise(varargin{:});
        end
        
        function varargout = nonlinearize(varargin)
            [varargout{1:nargout}] = nonlinearise(varargin{:});
        end
        
    end
    
    methods (Access=protected,Hidden)
        
       varargout = mychngplan(varargin) 
       
    end
    
end