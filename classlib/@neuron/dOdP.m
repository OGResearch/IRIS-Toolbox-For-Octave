function [out] = dOdP(This,in)
% pderiv  [Not a public function]
%
% First derivative of the output function with respect to the activation
% function parameters. 
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

out = dOdA(This,in).*dAdP(This,in) ;

end


