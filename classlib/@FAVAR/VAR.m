function w = VAR(f)
% VAR  Return a VAR object describing the factor dynamics.
%
% Syntax
% =======
%
%     v = VAR(a)
%
% Input arguments
% ================
%
% `a` [ FAVAR ] - FAVAR object.
%
% Output arguments
% =================
%
% `v` [ VAR ] - VAR object describing the dynamic system of the FAVAR
% factors.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

% TODO: Use parent VAR objects.

[~,nx,p,q,nalt] = size(f);

% Create and populate a struct.
w = struct();
w.A = f.A; % Untransformed transition matrices.
w.K = zeros([nx,nalt]); % Constant vector.
w.B = f.B;
w.std = 1;
w.Omega = f.Omega; % Cov of reduced-form residuals.
if q < nx
   for ialt = 1 : nalt
      w.Omega(:,:,ialt) = f.B(:,:,ialt)*f.B(:,:,ialt)';
   end
   w.B = [w.B,zeros([nx,nx-q,nalt])];
end
w.Sigma = []; % Cov of parameters.
w.T = f.T; % Shur decomposition of transition matrix.
w.U = f.U; % Schur transformation of variables.
w.range = f.range; % User range.
w.fitted = f.fitted; % Effective estimation sample.
w.Rr = []; % Parameter restrictions.
w.nhyper = nx*p; % Number of estimated hyperparameters.
w.eigval = f.eigval; % Vector of eigenvalues.
w.Ynames = @(n) sprintf('factor%g',n); % Names of endogenous variables.
w.Enames = @(yname,n) ['res_',yname]; % Names of residuals.
% w.aic, w.sbc to be populated within VAR().

% Convert the struct to a VAR object.
w = VAR(w);

end