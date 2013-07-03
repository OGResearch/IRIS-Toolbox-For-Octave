function This = demean(This)
% demean  Remove constant from VAR object.
%
% Syntax
% =======
%
%     V = demean(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object in which the constant vector will be reset to
% zero.
%
% Output arguments
% =================
%
% * `V` [ VAR ] - VAR object with the constant vector reset to zero.
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

This.K(:,:,:) = 0;

end