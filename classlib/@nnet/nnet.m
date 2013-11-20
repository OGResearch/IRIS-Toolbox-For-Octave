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
            
            % Superclass constructors.
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
        end

        function nAlt = get.nAlt(This)
            nAlt = size(This.Weights,2) ;
        end

        varargout = disp(varargin) ;
        varargout = size(varargin) ;
    end
    
end

