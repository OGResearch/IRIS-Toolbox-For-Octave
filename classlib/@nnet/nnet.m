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
        
        nActivationParams ;
        nOutputParams ;
        nHyperParams ;
        nParams ;
        
        Neuron@cell = cell(0,1) ;
    end
    
    properties( Dependent = true, Hidden = true )
        nInputs ;
        nOutputs ;
        nLayer ;
    end
    
    methods
        function This = nnet(Inputs,Outputs,Layout,varargin)
            % -IRIS Toolbox.
            % -Copyright (c) 2007-2013 IRIS Solutions Team.
            
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
            
            % Parse options
            options = passvalopt('nnet.nnet',varargin{:});
            if numel(options.Bias) == 1
                options.Bias = true(size(Layout)).*options.Bias ;
            end
            if ischar(options.ActivationFn)
                options.ActivationFn = cellfun(@(x) options.ActivationFn, cell(size(Layout)), 'UniformOutput', false) ;
            end
            if ischar(options.OutputFn)
                options.OutputFn = cellfun(@(x) options.OutputFn, cell(size(Layout)), 'UniformOutput', false) ;
            end
            This.ActivationFn = options.ActivationFn ;
            This.OutputFn = options.OutputFn ;
            This.Bias = options.Bias ;
            
            % Initialize layers of neurons
            ActivationIndex = 0 ;
            OutputIndex = 0 ;
            HyperIndex = 0 ;
            Nmax = max(This.Layout) ;
            nLayer = numel(Layout) ;
            This.Neuron = cell(nLayer,1) ;
            for iLayer = 1:nLayer
                NN = This.Layout(iLayer) + This.Bias(iLayer) ;
                pos = linspace(1,Nmax,NN) ;
                if iLayer == 1
                    nInputs = This.nInputs ;
                else
                    nInputs = numel(This.Neuron{iLayer-1}) ;
                end
                This.Neuron{iLayer} = cell(This.Layout(iLayer),1) ;
                for iNode = 1:This.Layout(iLayer)
                    Position = [iLayer,pos(iNode)] ;
                    This.Neuron{iLayer}{iNode} ...
                        = neuron(options.ActivationFn{iLayer},options.OutputFn{iLayer},nInputs,Position,...
                        ActivationIndex,OutputIndex,HyperIndex) ;
                    ActivationIndex = ActivationIndex + numel(This.Neuron{iLayer}{iNode}.ActivationIndex) ;
                    OutputIndex = OutputIndex + numel(This.Neuron{iLayer}{iNode}.OutputIndex) ;
                    HyperIndex = HyperIndex + numel(This.Neuron{iLayer}{iNode}.HyperIndex) ;
                end
                if options.Bias(iLayer)
                    Position = [iLayer,pos(This.Layout(iLayer)+1)] ;
                    This.Neuron{iLayer}{This.Layout(iLayer)+1} ...
                        = neuron('bias','bias',nInputs,Position,...
                        ActivationIndex,OutputIndex,HyperIndex) ;
                    ActivationIndex = ActivationIndex + numel(This.Neuron{iLayer}{iNode}.ActivationIndex) ;
                    OutputIndex = OutputIndex + numel(This.Neuron{iLayer}{iNode}.OutputIndex) ;
                    HyperIndex = HyperIndex + numel(This.Neuron{iLayer}{iNode}.HyperIndex) ;
                end
            end
            This.nActivationParams = ActivationIndex ;
            This.nOutputParams = OutputIndex ;
            This.nHyperParams = HyperIndex ;
            This.nParams = ActivationIndex + OutputIndex + HyperIndex ;
        end
        
        varargout = disp(varargin) ;
        varargout = size(varargin) ;
        varargout = datarequest(varargin) ;
        varargout = set(varargin) ;
        varargout = aeq(varargin) ;
        varargout = horzcat(varargin) ;
        varargout = vertcat(varargin) ;
        varargout = eval(varargin) ;
        varargout = plot(varargin) ;
        
        % Dependent methods
        function nInputs = get.nInputs(This)
            nInputs = numel(This.Inputs) ;
        end
        
        function nOutputs = get.nOutputs(This)
            nOutputs = numel(This.Outputs) ;
        end
        
        function nLayer = get.nLayer(This)
            nLayer = numel(This.Layout) ;
        end        
    end
    
    methods (Static,Hidden)
        varargout = myalias(varargin)
    end
    
    
end

