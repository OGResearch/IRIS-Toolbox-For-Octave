function [out] = dAdI(This,in)
% pderiv  [Not a public function]
%
% First derivative of the activation function with respect to the input. 
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

switch This.ActivationFn

    case 'bias'
		out = 0 ;
	
    case 'linear'
		out = repmat( This.ActivationParams(:)', size(in,1), 1 ) ;

    otherwise
        utils.error('nnet','Symbolic differentiation not available for activation function of type %s\n',This.OutputFn) ;
        
end


