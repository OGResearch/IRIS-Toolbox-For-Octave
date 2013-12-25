function [X,Flag,Query] = specget(This,Query)
% specget  [Not a public function] Implement GET method for nnet objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

try    
    switch Query
                
        case 'activation'
            X = NaN(This.nActivationParams,This.nAlt) ;
            for iLayer = 1:This.nLayer+1
                for iNode = 1:numel(This.Neuron{iLayer})
                    X(This.Neuron{iLayer}{iNode}.ActivationIndex,:) ...
                        = This.Neuron{iLayer}{iNode}.ActivationParams ;
                end
            end
            Flag = true ;
            
        case 'activationlb'
            X = NaN(This.nActivationParams,1) ;
            for iLayer = 1:This.nLayer+1
                for iNode = 1:numel(This.Neuron{iLayer})
                    X(This.Neuron{iLayer}{iNode}.ActivationIndex,:) ...
                        = This.Neuron{iLayer}{iNode}.ActivationLB ;
                end
            end
            Flag = true ;

        case 'activationub'
            X = NaN(This.nActivationParams,1) ;
            for iLayer = 1:This.nLayer+1
                for iNode = 1:numel(This.Neuron{iLayer})
                    X(This.Neuron{iLayer}{iNode}.ActivationIndex,:) ...
                        = This.Neuron{iLayer}{iNode}.ActivationUB ;
                end
            end
            Flag = true ;

        case 'activationindex'
            X = 1:This.nActivationParams ;
            Flag = true ;
        
        case 'output'
            X = NaN(This.nOutputParams,This.nAlt) ;
            for iLayer = 1:This.nLayer+1
                for iNode = 1:numel(This.Neuron{iLayer})
                    X(This.Neuron{iLayer}{iNode}.OutputIndex,:) ...
                        = This.Neuron{iLayer}{iNode}.OutputParams ;
                end
            end
            Flag = true ;
        
        case 'outputlb'
            X = NaN(This.nOutputParams,1) ;
            for iLayer = 1:This.nLayer+1
                for iNode = 1:numel(This.Neuron{iLayer})
                    X(This.Neuron{iLayer}{iNode}.OutputIndex,:) ...
                        = This.Neuron{iLayer}{iNode}.OutputLB ;
                end
            end
            Flag = true ;
        
        case 'outputub'
            X = NaN(This.nOutputParams,1) ;
            for iLayer = 1:This.nLayer+1
                for iNode = 1:numel(This.Neuron{iLayer})
                    X(This.Neuron{iLayer}{iNode}.OutputIndex,:) ...
                        = This.Neuron{iLayer}{iNode}.OutputUB ;
                end
            end
            Flag = true ;
            
        case 'hyper'
            X = NaN(This.nHyperParams,This.nAlt) ;
            for iLayer = 1:This.nLayer+1
                for iNode = 1:numel(This.Neuron{iLayer})
                    X(This.Neuron{iLayer}{iNode}.HyperIndex,:) ...
                        = This.Neuron{iLayer}{iNode}.HyperParams ;
                end
            end
            Flag = true ;
            
        case 'hyperlb'
            X = NaN(This.nHyperParams,1) ;
            for iLayer = 1:This.nLayer+1
                for iNode = 1:numel(This.Neuron{iLayer})
                    X(This.Neuron{iLayer}{iNode}.HyperIndex,:) ...
                        = This.Neuron{iLayer}{iNode}.HyperLB ;
                end
            end
            Flag = true ;

        case 'hyperub'
            X = NaN(This.nHyperParams,1) ;
            for iLayer = 1:This.nLayer+1
                for iNode = 1:numel(This.Neuron{iLayer})
                    X(This.Neuron{iLayer}{iNode}.HyperIndex,:) ...
                        = This.Neuron{iLayer}{iNode}.HyperUB ;
                end
            end
            Flag = true ;
                                    
        otherwise
            Flag = false ;
    end
catch
    Flag = false ;
end

end
