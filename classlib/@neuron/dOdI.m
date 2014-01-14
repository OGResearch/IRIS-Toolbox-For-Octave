function [out] = dOdI(This,in)
% pderiv  [Not a public function]
%
% First derivative of the output function with respect to the inputs. 
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

out = dOdA(This,in).*dAdI(This,in) ;

end


