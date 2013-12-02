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
        nParams ;
        nBias ;
        nWeight ;
        nTransfer ;
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
            This = set(This,'weight',options.initWeight) ;
            This = set(This,'bias',options.initBias) ;
            This = set(This,'transfer',options.initTransfer) ;
        end
        
        varargout = disp(varargin) ;
        varargout = size(varargin) ;
        varargout = datarequest(varargin) ;
        varargout = set(varargin) ;
        varargout = aeq(varargin) ;
        varargout = horzcat(varargin) ;
        varargout = vertcat(varargin) ;
        varargout = eval(varargin) ;
        
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
        
        function nWeight = get.nWeight(This)
            nWeight = 0 ;
            for iLayer = 1:This.nLayer+2
                if iLayer>1
                    for iNode = 1:numel(This.Params{iLayer}.Weight)
                        for iInput = 1:numel(This.Params{iLayer}.Weight{iNode})
                            nWeight = nWeight + 1;
                        end
                    end
                end
            end
        end
        
        function nBias = get.nBias(This)
            nBias = 0 ;
            for iLayer = 1:This.nLayer+2
                for iNode = 1:numel(This.Params{iLayer}.Bias)
                    nBias = nBias + 1 ;
                end
            end
        end
        
        function nTransfer = get.nTransfer(This)
            nTransfer = 0 ;
            for iLayer = 1:This.nLayer+2
                for iNode = 1:numel(This.Params{iLayer}.Transfer)
                    nTransfer = nTransfer + 1 ;
                end
            end
        end
        
        function nParams = get.nParams(This)
            nParams = This.nWeight + This.nBias + This.nTransfer ;
        end
        
    end
    
    methods (Static,Hidden)
        varargout = myalias(varargin)
    end
    
    
end

