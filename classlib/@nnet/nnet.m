classdef nnet < userdataobj & getsetobj
    
    properties
        % 'feedforward'
        Type = '' ;
        
        % cell array of variables
        Inputs = cell(0,1) ;
        
        % e.g. [2 8 5]
        HiddenLayout = [] ;
        
        % e.g. 'tanh','sigmoid','step','linear'
        HiddenTransfer = cell(0,1) ;
        InputTransfer = '' ;
        OutputTransfer = '' ;
        
        % Cell array of structs: 
        Params = cell(0,1) ;
        % Rows:
        %    Input
        %    Layer 1
        %    ...
        %    Layer N
        %    Output
        % Columns:
        %    Alternative parameterizations 
        
        % cell array of variables
        Outputs = cell(0,1) ;
    end
    
    properties( Dependent = true )
        nAlt ;
        nInputs ;
        nOutputs ;
        nLayer ;
    end
    
    methods( Static )
        varargout = initConv(varargin) ;
    end
    
    methods
        function This = nnet(Inputs,Outputs,HiddenLayout,varargin)
            % -IRIS Toolbox.
            % -Copyright (c) 2007-2013 IRIS Solutions Team.
            
            pp = inputParser() ;
            pp.addRequired('Inputs',@(x) iscellstr(x) || ischar(x)) ;
            pp.addRequired('Outputs',@(x) iscellstr(x) || ischar(x)) ;
            pp.addRequired('HiddenLayout',@(x) isvector(x) && isnumeric(x)) ;
            pp.parse(Inputs,Outputs,HiddenLayout) ;

            % Parse options
            options = passvalopt('nnet.nnet',varargin{:});
            
            % Superclass constructors
            This = This@userdataobj();
            This = This@getsetobj();
            
            % Construct
            This.Inputs = cellstr(Inputs) ;
            This.Outputs = cellstr(Outputs) ;
            This.HiddenLayout = HiddenLayout ;
            
            if iscellstr(options.HiddenTransfer)
                This.HiddenTransfer = options.HiddenTransfer ;
            else
                This.HiddenTransfer = cellfun(@(x) options.HiddenTransfer, cell(numel(This.HiddenLayout),1), 'UniformOutput', false) ;
            end
            This.InputTransfer = options.InputTransfer ;
            This.OutputTransfer = options.OutputTransfer ;
            This.Type = options.Type ;
            
            % *** Construct initial parameters ***
            myStruct = struct() ;
            
            % No weighting possible at input nodes
            This.Params ...
                = cellfun(@(x) myStruct, cell(This.nLayer+2,1), 'UniformOutput', false) ;
            This.Params{1}.Bias ...
                = cellfun(any2func(options.initBias), cell(This.nInputs,1), 'UniformOutput', false) ;
            This.Params{1}.Transfer ...
                = cellfun(any2func(options.initTransfer), cell(This.nInputs,1), 'UniformOutput', false) ;
            
            % First nodes weight inputs
            initW = cell2mat(arrayfun(any2func(options.initWeight), ones(This.nInputs,1), 'UniformOutput', false)) ;
            This.Params{2}.Weight ...
                = cellfun(@(x) initW, cell(This.HiddenLayout(1),1), 'UniformOutput', false) ;
            This.Params{2}.Bias ...
                = cellfun(any2func(options.initWeight), cell(This.HiddenLayout(1),1), 'UniformOutput', false) ;
            This.Params{2}.Transfer ...
                = cellfun(any2func(options.initTransfer), cell(This.HiddenLayout(1),1), 'UniformOutput', false) ;

            % Subsequent nodes weight outputs of previous layer
            for iLayer = 2:This.nLayer
                initW = ones(This.HiddenLayout(iLayer-1),1) ; 
                This.Params{iLayer+1}.Weight ...
                    = cellfun(@(x) initW, cell(This.HiddenLayout(iLayer),1), 'UniformOutput', false) ;
                This.Params{iLayer+1}.Bias ...
                    = cellfun(any2func(options.initWeight), cell(This.HiddenLayout(iLayer),1), 'UniformOutput', false) ;
                This.Params{iLayer+1}.Transfer ...
                    = cellfun(any2func(options.initTransfer), cell(This.HiddenLayout(iLayer),1), 'UniformOutput', false) ;
            end
            
            % Output nodes weight outputs of last layer
            initW = ones(This.HiddenLayout(end),1) ;
            This.Params{end}.Weight ...
                = cellfun(@(x) initW, cell(This.nOutputs,1), 'UniformOutput', false) ;
            This.Params{end}.Bias ...
                = cellfun(any2func(options.initBias), cell(This.nOutputs,1), 'UniformOutput', false) ;
            This.Params{end}.Transfer ...
                = cellfun(any2func(options.initTransfer), cell(This.nOutputs,1), 'UniformOutput', false) ;
        end

        varargout = disp(varargin) ;
        varargout = size(varargin) ;
        varargout = datarequest(varargin) ;

        % Dependent methods
        function nAlt = get.nAlt(This)
            nAlt = size(This.Params,2) ;
        end
        
        function nInputs = get.nInputs(This)
            nInputs = numel(This.Inputs) ;
        end
        
        function nOutputs = get.nOutputs(This)
            nOutputs = numel(This.Outputs) ;
        end
        
        function nLayer = get.nLayer(This)
            nLayer = numel(This.HiddenLayout) ;
        end

    end
    
end

