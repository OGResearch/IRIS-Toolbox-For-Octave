function [Obj,Pred] = objfunc(This,InData,OutData,Range,options)
% OBJFUNC  [Not a public function] Objective function value.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.
    
%**************************************************************************

Pred = tseries(Range,NaN(size(OutData))) ;
switch This.Type
    case 'feedforward'
        % Input Layer
        InLayer = tseries(Range, NaN(length(Range),This.nInputs)) ;
        for iInput = 1:This.nInputs
            InLayer(Range,iInput) ...
                = xxNodeTransfer(...
                    InData{Range,iInput}, ...
                    1.0, ...
                    This.Params{1}, ...
                    This.InputTransfer...
                    ) ;
        end
        
        % Hidden Layers
        for iLayer = 1:This.nLayer
            OutLayer = tseries(Range, NaN(length(Range),This.HiddenLayout(iLayer))) ;
            for iNode = 1:This.HiddenLayout(iLayer)
                OutLayer(Range,iNode) ...
                    = xxNodeTransfer(...
                        InLayer{Range,:}, ...
                        This.Params{iLayer+1}.Weight{iNode},...
                        This.Params{iLayer+1}, ...
                        This.HiddenTransfer{iLayer}...
                        ) ;
            end
            InLayer = OutLayer ;
        end
        
        % Output Layers
        for iOutput = 1:This.nOutputs
            Pred(Range,iOutput) ...
                = xxNodeTransfer(...
                    OutLayer{Range,:}, ...
                    This.Params{end}.Weight{iOutput}, ...
                    This.Params{end}, ...
                    This.OutputTransfer...
                    ) ;
        end
        
    otherwise
        utils.error('nnet:objfunc',...
            'Unsupported neural network type.') ;
end

Obj = options.Norm(OutData-Pred) ;

    function Output = xxNodeTransfer(Input, Weight, Params, Transfer) 
        switch Transfer
            case 'sigmoid'
                X = ( 1./(1-exp(-Input.*Params.Transfer)) ) ;
            case 'tanh'
                X = ( 1-exp(-Params.Transfer.*Input) )./( 1+exp(-Params.Transfer.*Input) ) ;
            case 'step'
                X = ( Input>0 ) ;
            case 'linear'
                X = Input ;
        end
        Output = Params.Bias + sum(Weight'.*X,2) ;
    end

end
