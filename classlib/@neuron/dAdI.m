function [out] = dAdI(This,in)
% pderiv  [Not a public function]
%
% First derivative of the activation function with respect to the input. 
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

T = length(in) ;
switch This.ActivationFn
	
    case 'bias'
		out = 0 ;
	
    case 'linear'
		out = repmat( This.ActivationParams(:)', T, 1 ) ;
        
end


