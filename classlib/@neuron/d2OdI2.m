function [out] = d2OdI2(This,in)
% dAdI  [Not a public function]
%
% Second derivative of the output function with respect to the input.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Second argument is the second derivative w.r.t. the input

switch This.OutputFn
    case 's4'
        out = -(3*This.OutputParams^3*in)./(This.OutputParams^2*in.^2+1)^5/2 ;
    case 'logistic'
        tmp = exp(This.OutputParams*in) ;
        out = -(2*This.OutputParams^2*tmp.*(tmp-1))./(tmp+1).^3 ;
    case 'tanh'
        tmp = exp(This.OutputParams*in) ;
        out = -(2*This.OutputParams^2*tmp.*(tmp-1))./(tmp+1).^3 ;
end

end


