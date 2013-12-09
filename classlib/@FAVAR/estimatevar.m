function [A,B,Omega,T,U,u,fitted] = estimatevar(x,p,q)
% estimatevar  Estimate VAR(p,q) on factors.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

nx = size(x,1);
nper = size(x,2);

% Stack vectors of x(t), x(t-1), etc.
t = p+1 : nper;
presample = nan(nx,p);
x0 = [presample,x(:,t)];
x1 = [];
for i = 1 : p
   x1 = [x1;presample,x(:,t-i)]; %#ok<AGROW>
end

% Determine dates with no missing observations.
fitted = all(~isnan([x0;x1]));
nobs = sum(fitted);

% Estimate VAR and reduced-form residuals.
A = x0(:,fitted)/x1(:,fitted);
e = x0 - A*x1;
Omega = e(:,fitted)*e(:,fitted)'/nobs;

% Number of orthonormalised shocks driving the factor VAR.
if q > nx
   q = nx;
end

% Compute principal components of reduced-form residuals, back out
% orthonormalised residuals.
% e = B u,
% Euu' = I.
[B,u] = covfun.orthonorm(Omega,q,1,e);
B = B(:,1:q,:);
u = u(1:q,:,:);

% Tringularise FAVAR system.
%     x = A [x(-1);...;x(-p)] + [B;0] u
%     a = T a(-1) + U(1:nx,:)' B u.
% where x = U a.
AA = [A;eye(nx*(p-1),nx*p)];
[U,T] = schur(AA);

end
