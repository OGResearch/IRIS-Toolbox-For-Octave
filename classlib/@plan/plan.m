classdef plan < userdataobj & getsetobj
    % plan  Simulation Plans.
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
        Start = NaN;
        End = NaN;
        XList = {}; % List of names that can be exogenized.
        NList = {}; % List of names that can be endogenized.
        QList = {};
        CList = {}; % List of names upon which it can be conditioned.
        XAnch = []; % Exogenised.
        NAnchReal = []; % Endogenised real.
        NAnchImag = []; % Endogenised imag.
        NWghtReal = []; % Weights for endogenised real.
        NWghtImag = []; % Weights for endogenised imag.
        CAnch = []; % Conditioned.
        QAnch = []; % Non-linearised.
        AutoEx = [];
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
            % * simulations or forecasts with some of the model variables temporarily
            % exogenised;
            %
            % * simulations with some of the non-linear equations solved exactly.
            %
            % * forecasts conditioned upon some variables;
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
                pp.addRequired('M',@(x) myisa(x,'modelobj'));
                pp.addRequired('Range',@isnumeric);
                pp.parse(varargin{1:2});

                
                % Range.
                This.Start = varargin{2}(1);
                This.End = varargin{2}(end);
                nPer = round(This.End - This.Start + 1);
                % Exogenising.
                This.XList = myget(varargin{1},'canbeexogenised');
                This.XAnch = false(length(This.XList),nPer);
                % Endogenising.
                This.NList = myget(varargin{1},'canbeendogenised');
                This.NAnchReal = false(length(This.NList),nPer);
                This.NAnchImag = false(length(This.NList),nPer);
                This.NWghtReal = zeros(length(This.NList),nPer);
                This.NWghtImag = zeros(length(This.NList),nPer);
                % Non-linearising.
                This.QList = myget(varargin{1},'canbenonlinearised');
                This.QAnch = false(length(This.QList),nPer);
                % Conditioning.
                This.CList = This.XList;
                This.CAnch = This.XAnch;
                % Autoexogenise.
                This.AutoEx = nan(size(This.XList));
                try %#ok<TRYNC>
                    auto = autoexogenise(varargin{1});
                    XList = fieldnames(auto); %#ok<PROP>
                    NList = struct2cell(auto); %#ok<PROP>
                    na = length(XList); %#ok<PROP>
                    for ia = 1 : na
                        xInx = strcmp(This.XList,XList{ia}); %#ok<PROP>
                        nInx = strcmp(This.NList,NList{ia}); %#ok<PROP>
                        This.AutoEx(xInx) = find(nInx);
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