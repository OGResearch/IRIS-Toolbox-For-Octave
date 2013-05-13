function D = addparam(This,D)
% addparam  Add VAR parameters to a database (struct).
%
% Syntax
% =======
%
%     D = addparam(V,D)
%
% Input arguments
% ================
%
% * `V` [ SVAR ] - SVAR object whose parameter matrices will be added to
% database (struct) `D`.
%
% * `D` [ struct ] - Database to which the model parameters will be added.
%
% Output arguments
% =================
%
% * `D [ struct ] - Database with the VAR parameters added.
%
% Description
% ============
%
% The newly created database entries are named `A` (transition matrix), `K`
% (constant terms), `B` (matrix in front of structural residuals), and
% `Omg` (covariance matrix of shocks). Be aware that if there are database
% entries in `D` whose names conincide with these names, they will be
% overwritten.
%
% Example
% ========
%
%     D = struct();
%     D = addparam(V,D);
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    D; %#ok<VUNUS>
catch %#ok<CTCH>
    D = struct();
end

%--------------------------------------------------------------------------

D = addparam@VAR(This,D);
D.B = This.B;

end
