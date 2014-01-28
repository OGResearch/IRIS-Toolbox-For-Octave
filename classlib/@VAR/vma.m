function Phi = vma(This,N)
% vma  Matrices describing the VMA representation of a VAR process.
%
% Syntax
% =======
%
%     Phi = vma(V,N)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object for which the VMA matrices will be computed.
%
% * `N` [ numeric ] - Order up to which the VMA matrices will be computed.
%
% Output arguments
% =================
%
% * `Phi` [ numeric ] - VMA matrices.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('V',@(x) isa(x,'VAR'));
pp.addRequired('N',@is.numericscalar);
pp.parse(This,N);

%--------------------------------------------------------------------------

[A,B] = mysystem(This);
Phi = timedom.var2vma(A,B,N);

end