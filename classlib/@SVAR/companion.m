function varargout = companion(This,varargin)
% companion  Matrices for first-order companion SVAR.
%
% Syntax
% =======
%
%     [A,B,K] = companion(S)
%
% Input arguments
% ================
%
% * `S` [ VAR ] - VAR object for which the companion
% matrices will be returned.
%
% Output arguments
% =================
%
% * `A` [ numeric ] - First-order companion transition matrix.
%
% * `B` [ numeric ] - First-order companion coefficient matrix at
% structural residuals.
%
% * `K` [ numeric ] - First-order companion constant vector.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

[varargout{1:nargout}] = companion@VAR(This,varargin{:});

if nargout > 1
   varargout{2} = [This.B;zeros(ny*(p-1),ny,nAlt)];
end

end