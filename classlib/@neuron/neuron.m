classdef neuron < handle
    % neuron  [Not a public class definition]
    % 
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.
    
    properties
        ActivationFn@char = '' ;
        ActivationParams = [] ;
        ActivationIndex = [] ;
        ActivationBounds = [] ;
        ActivationBoundsDefault = [] ;
        
        OutputFn@char = '' ;
        OutputParams = [] ;
        OutputIndex = [] ;
        OutputBounds = [] ;
        OutputBoundsDefault = [] ;
        
        HyperParams = [] ;
        HyperIndex = [] ;
        HyperBounds = [] ;
        HyperBoundsDefault = [] ;
        
        ForwardConnection = {} ;
        BackwardConnection = {} ;
        
        Position@double = [NaN,NaN] ;
        nAlt = NaN ;
        Bias = false ;
    end
        
    methods
        
        function This = neuron(ActivationFn,OutputFn,nInputs,Position,ActivationIndex,OutputIndex,HyperIndex)
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
            This.ActivationBoundsDefault = [-Inf,Inf] ;
            This.ActivationBounds = repmat(This.ActivationBoundsDefault,numel(This.ActivationParams),1) ;
            
            % Output
            This.OutputFn = OutputFn ;
            This.OutputParams = NaN ;
            This.OutputIndex = OutputIndex+1:OutputIndex+numel(This.OutputParams) ;
            This.OutputBoundsDefault = [0,Inf] ;
            This.OutputBounds = repmat(This.OutputBoundsDefault,numel(This.OutputParams),1) ;
            
            % Hyper
            This.HyperParams = NaN ;
            This.HyperIndex = HyperIndex+1 ;
            switch ActivationFn
                case 'minkovsky'
                    This.HyperParams = 2 ;
                otherwise
                    This.HyperParams = 1 ;
            end
            This.HyperBoundsDefault = [0,Inf] ;
            This.HyperBounds = repmat(This.HyperBoundsDefault,numel(This.HyperParams),1) ;
            
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
        
        varargout = eval(varargin) ;
        varargout = saliency(varargin) ;
        
    end
end