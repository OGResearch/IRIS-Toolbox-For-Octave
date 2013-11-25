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
% * `V` [ VAR ] - VAR object whose parameter matrices will be added to
% database (struct) `D`.
%
% * `D` [ struct ] - Database to which the model parameters will be added.
%
% Output arguments
% =================
%
% * `D [ struct ] - Database with the VAR parameter matrices added.
%
% Description
% ============
%
% The newly created database entries are named `A_` (transition matrix),
% `K_` (constant terms), `B_` (matrix of instantaneous whock effects), and
% `Cov_` (covariance matrix of shocks). Be aware that all existing database
% entries in `D` named `A_`, `K_`, `B_`, or `Omg_` will be overwritten.
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

D.A_ = This.A;
D.B_ = mybmatrix(This);
D.K_ = This.K;
D.Cov_ = mycovmatrix(This);

end