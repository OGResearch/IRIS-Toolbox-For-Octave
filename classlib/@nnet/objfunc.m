function [Obj,Pred] = objfunc(X,This,InData,OutData,Range,options)
% OBJFUNC  [Not a public function] Objective function value.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.
    
%**************************************************************************

[This,Flag] = myupdatemodel(This,X,options) ;
if ~Flag
    utils.error('nnet:objfunc',...
        'Parameter update failure.') ;
end

Pred = eval(This,InData,Range) ; %#ok<*GTARG>

Obj = options.Norm(OutData-Pred)/length(OutData) ;

    function Output = xxNodeTransfer(Input, Weight, Bias, Transfer, TransferParam) 
        switch Transfer
            case 'sigmoid'
                X = ( 1./(1-exp(-Input.*TransferParam)) ) ;
            case 'tanh'
                X = ( 1-exp(-TransferParam.*Input) )./( 1+exp(-TransferParam.*Input) ) ;
            case 'step'
                X = ( Input>0 ) ;
            case 'linear'
                X = Input ;
        end
        Output = Bias + sum(Weight'.*X,2) ;
    end

end
