classdef neuron
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.
    
    properties
        ActivationFn@char = '' ;
        ActivationParams = [] ;
        ActivationIndex = [] ;
        OutputFn@char = '' ;
        OutputParams = [] ;
        OutputIndex = [] ;
        
        Position@double = [NaN,NaN] ;
        nAlt = NaN ;
        Bias = false ;
    end
    
    methods
        
        function This = neuron(ActivationFn,OutputFn,nInputs,Position,ActivationIndex,OutputIndex)
            % neuron  [Not a public function]
            %
            % Backend IRIS function.
            % No help provided.
            
            % -IRIS Toolbox.
            % -Copyright (c) 2007-2013 IRIS Solutions Team.
            
            % Activation
            This.ActivationFn = ActivationFn ;
            This.ActivationParams = NaN(nInputs,1) ;
            This.ActivationIndex = ActivationIndex+1:ActivationIndex+numel(This.ActivationParams) ;
            
            % Output
            This.OutputFn = OutputFn ;
            This.OutputParams = NaN ;
            This.OutputIndex = OutputIndex+1:OutputIndex+numel(This.OutputParams) ;
            
            % Everything else
            This.nAlt = 1 ;
            This.Position = Position ;
            switch ActivationFn
                case 'bias'
                    This.Bias = true ;
                otherwise
                    This.Bias = false ;
            end
        end
        
        varargout = eval(varargin)
        
    end
end