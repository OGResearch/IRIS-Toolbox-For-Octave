function [out] = dAdP(This,in)
% pderiv  [Not a public function]
%
% First derivative of the activation function with respect to the 
% activation parameters. 
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

switch This.ActivationFn
    case 'linear'
        out = in ; 
        
    otherwise
        utils.error('nnet','Symbolic differentiation not available for activation function of type %s\n',This.OutputFn) ;
        
end


