classdef nnet < userdataobj & getsetobj
    
    properties
        % cell array of variables
        Inputs@cell = cell(0,1) ;
        Outputs@cell = cell(0,1) ;
        
        ActivationFn@cell = cell(0,1) ;
        OutputFn@cell = cell(0,1) ;
        Bias = false ;
        nAlt ;
        
        Layout = [] ;
        
        nPruned ;
        nActivationParams ;
        nOutputParams ;
        nHyperParams ;
        nParams ;
        
        Neuron@cell = cell(0,1) ;

        nInputs ;
        nOutputs ;
        nLayer ;
    end
    
    methods
        function This = nnet(Inputs,Outputs,Layout,varargin)
            % nnet  Neural network model constructor method.
            %
            % Syntax
            % =======
            %
            %     [PEst,Pos,Cov,Hess,M,V,Delta,PDelta] = estimate(M,D,Range,Est,...)
            %     [PEst,Pos,Cov,Hess,M,V,Delta,PDelta] = estimate(M,D,Range,Est,SPr,...)
            %
            % Input arguments
            % ================
            %
            % * `Inputs` [ cellstr | char ] - Variable name or cell array
            % of variable names. 
            % 
            % * `Outputs` [ cellstr | char ] - Variable name or cell array
            % of variable names. 
            % 
            % Both input and output arguments can include lead/lag
            % operators. E.g., nnet({'x{-1}','x{-2}'},'x',...)
            % 
            % * `Layout` [ numeric ] - Vector of integers with length equal
            % to the number of layers such that each element specifies the
            % number of nodes in that hidden layer. 
            %
            % Output arguments
            % =================
            %
            % * `M` [ nnet ] - Neural network model object. 
            %
            % Options
            % ========
            %
            % * `'ActivationFn='` [ *`linear`* | `minkovsky` ] - Activation function. 
            % 
            % * `'OutputFn='` [ *`logistic`* | `s4` | `tanh` ] - Output function. 
            % 
            % The composition of the activation and output functions is
            % used to create flexible transfer functions. 
            %
            % Description
            % ============
            % 
            % Implements a wide variety of neural network structures,
            % such as multi-layer feedforward and radial 
            % basis networks, including multi-layer perceptrons. 
            % Recurrent neural networks are unsupported at present.  
            % Transfer functions are the composition of an
            % activation and an output function, as in Duch and Jankowski
            % (1999). Features include: 
            % 
            % * Network training using a variety of optimization methods,
            % including particle swarm optimization.  
            % * Network pruning as in Kaashoek and Van Dijk (2002) to mitigate 
            % overfitting problems. 
            % * Network architecture visualisation. 
            % * K-step ahead forecasts. 
            % * Parallel network pruning and training algorithms. 
            % 
            % References
            % ===========
            %
            % # Duch, Wlodzislaw; Jankowski, Norbert (1999). "Survey of
            %   neural transfer functions," Neural Computing Surveys 2
            % 
            % # Gorodkin, J., Hansen, L.K., Krogh, A., Savarer, C., and
            % Winther, O. (1993). "A quantitative study of pruning by
            % optimal brain damage," mimeo. 
            % 
            % # Kaashoek, Johan F., and Van Dijk, Herman K. (2002). "Neural
            % network pruning applied to real exchange rate analysis,"
            % Journal of Forecasting. 
            %
            % -IRIS Toolbox.
            % -Copyright (c) 2007-2014 IRIS Solutions Team.
            
            pp = inputParser() ;
            pp.addRequired('Inputs',@(x) iscellstr(x) || ischar(x)) ;
            pp.addRequired('Outputs',@(x) iscellstr(x) || ischar(x)) ;
            pp.addRequired('Layout',@(x) isvector(x) && isnumeric(x)) ;
            pp.parse(Inputs,Outputs,Layout) ;
            
            % Superclass constructors
            This = This@userdataobj();
            
            % Construct
            This.Inputs = cellstr(Inputs) ;
            This.Outputs = cellstr(Outputs) ;
            This.Layout = Layout ;
            This.nAlt = 1 ;
            
            This.nLayer = numel(This.Layout) ;
            This.nInputs = numel(This.Inputs) ;
            This.nOutputs = numel(This.Outputs) ;
            This.nPruned = 0 ;
            
            % Parse options
            options = passvalopt('nnet.nnet',varargin{:});
            if numel(options.Bias) == 1
                options.Bias = true(size(Layout)).*options.Bias ;
            end
            if ischar(options.ActivationFn)
                options.ActivationFn = cellfun(@(x) options.ActivationFn, cell(1,This.nLayer+1), 'UniformOutput', false) ;
            end
            if ischar(options.OutputFn)
                options.OutputFn = cellfun(@(x) options.OutputFn, cell(1,This.nLayer+1), 'UniformOutput', false) ;
            end
            This.ActivationFn = options.ActivationFn ;
            This.OutputFn = options.OutputFn ;
            This.Bias = options.Bias ;
            
            % Initialize layers of neurons
            ActivationIndex = 0 ;
            OutputIndex = 0 ;
            HyperIndex = 0 ;
            Nmax = max(This.Layout) ;
            This.Neuron = cell(This.nLayer+1,1) ;
            for iLayer = 1:This.nLayer
                NN = This.Layout(iLayer) + This.Bias(iLayer) ;
                pos = linspace(1,Nmax,NN) ;
                if iLayer == 1
                    nInput = This.nInputs ;
                else
                    nInput = numel(This.Neuron{iLayer-1}) ;
                end
                This.Neuron{iLayer} = cell(This.Layout(iLayer),1) ;
                for iNode = 1:This.Layout(iLayer)
                    Position = [iLayer,pos(iNode)] ;
                    This.Neuron{iLayer}{iNode} ...
                        = neuron(options.ActivationFn{iLayer},...
                        options.OutputFn{iLayer},...
                        nInput,...
                        Position,...
                        ActivationIndex,OutputIndex,HyperIndex) ;
                    xxUpdateIndex() ;
                end
                if options.Bias(iLayer)
                    Position = [iLayer,pos(This.Layout(iLayer)+1)] ;
                    This.Neuron{iLayer}{This.Layout(iLayer)+1} ...
                        = neuron('bias','bias',nInput,Position,...
                        ActivationIndex,OutputIndex,HyperIndex) ;
                    xxUpdateIndex() ;
                end
            end
            iLayer = This.nLayer + 1 ;
            This.Neuron{iLayer} = cell(This.nOutputs,1) ;
            for iNode = 1:This.nOutputs
                This.Neuron{iLayer}{iNode} ...
                    = neuron(options.ActivationFn{iLayer},...
                    options.OutputFn{iLayer},...
                    This.Layout(This.nLayer)+This.Bias(This.nLayer),...
                    [NaN,NaN],...
                    ActivationIndex,OutputIndex,HyperIndex) ;
                xxUpdateIndex() ;
            end
            
            This.nActivationParams = ActivationIndex ;
            This.nOutputParams = OutputIndex ;
            This.nHyperParams = HyperIndex ;
            This.nParams = ActivationIndex + OutputIndex + HyperIndex ;
            
            This = set(This,'hyper',1,'activation',0,'output',1) ;
            
            % Tell nodes about their forward/backward connections
            for iLayer = 1:This.nLayer+1
                for iNode = 1:numel(This.Neuron{iLayer})
                    if iLayer < This.nLayer+1
                        This.Neuron{iLayer}{iNode}.ForwardConnection ...
                            = cell( numel(This.Neuron{iLayer+1}), 1 ) ;
                        for sLayer = 1:numel(This.Neuron{iLayer+1})
                            This.Neuron{iLayer}{iNode}.ForwardConnection{sLayer} ...
                                = This.Neuron{iLayer+1}{sLayer} ;
                        end
                    end
                    if iLayer > 1
                        This.Neuron{iLayer}{iNode}.BackwardConnection ...
                            = cell( numel(This.Neuron{iLayer-1}), 1 ) ;
                        for sLayer = 1:numel(This.Neuron{iLayer-1})
                            This.Neuron{iLayer}{iNode}.BackwardConnection{sLayer} ...
                                = This.Neuron{iLayer-1}{sLayer} ;
                        end
                    end
                end
            end
            
            function xxUpdateIndex()
                ActivationIndex = ActivationIndex + numel(This.Neuron{iLayer}{iNode}.ActivationIndex) ;
                OutputIndex = OutputIndex + numel(This.Neuron{iLayer}{iNode}.OutputIndex) ;
                HyperIndex = HyperIndex + numel(This.Neuron{iLayer}{iNode}.HyperIndex) ;
            end
        end
        
        varargout = disp(varargin) ;
        varargout = size(varargin) ;
        varargout = set(varargin) ;
        varargout = eval(varargin) ;
        varargout = plot(varargin) ;
        varargout = prune(varargin) ;
        varargout = isnan(varargin) ;
        
        % Destructor method
        function delete(This)
            for iLayer = 1:This.nLayer+1
                for iNode = 1:numel(This.Neuron{iLayer})
                    delete( This.Neuron{iLayer}{iNode} ) ;
                end
            end
        end
    end
    
    methods( Hidden )
        varargout = assign(varargin) ;
        varargout = rmnan(varargin) ;
        varargout = myrange(varargin) ;
        varargout = mysameio(varargin) ;
        varargout = datarequest(varargin) ;
        varargout = horzcat(varargin) ;
        varargout = vertcat(varargin) ;
    end
    
    methods( Static, Hidden )
        varargout = myalias(varargin)
    end
    
    
end

