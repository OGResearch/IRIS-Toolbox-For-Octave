function This = rmnan(This) 

% rmnan  []
%
% This is the only function which changes network layout, and is only
% called by `prune`. 
% 
% Only works for activation parameters at this point. 

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if ~isnan(This)
    return ;
else
    
    for iLayer = 1:This.nLayer+1 
        for iNode = 1:numel(This.Neuron{iLayer})
            activationParams = get(This.Neuron{iLayer}{iNode},'activation') ;
            chk = isnan(activationParams) ;
            nNaN = sum(chk) ;
            if nNaN>0
                % Adjust global count
                This.nActivationParams = This.nActivationParams - nNaN ;
                
                % Adjust local indices in current node
                This.Neuron{iLayer}{iNode}.activationRemovedLocal = [This.activationRemovedLocal; This.activationIndexLocal(chk)] ;
                This.Neuron{iLayer}{iNode}.activationIndexLocal(chk) = [] ;
                
                % Adjust global indices and parameters in current node
                This.Neuron{iLayer}{iNode}.activationParams(chk) = [] ; 
                This.Neuron{iLayer}{iNode}.activationBounds(chk,:) = [] ;
                indexStart = This.Neuron{iLayer}{iNode}.activationIndex(1) ;
                This.Neuron{iLayer}{iNode}.activationIndex ...
                    = indexStart:indexStart+numel(This.Neuron{iLayer}{iNode}.activationParams) ;
                
                % Adjust global indices in subsequent 
                for sNode = iNode+1:numel(This.Neuron{iLayer})
                    This.Neuron{iLayer}{sNode}.activationIndex ...
                        = This.Neuron{iLayer}{sNode}.activationIndex - nNaN ; 
                end
                for sLayer = iLayer+1:This.nLayer+1 
                    for sNode = 1:numel(This.Neuron{sLayer})
                        This.Neuron{sLayer}{sNode}.activationIndex ...
                            = This.Neuron{sLayer}{sNode}.activationIndex - nNaN ;
                    end
                end
            end
        end
    end
    
end

end

