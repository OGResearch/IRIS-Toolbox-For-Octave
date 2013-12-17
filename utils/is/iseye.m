function flag = iseye(x,tol)
if nargin < 2
  tol = getrealsmall();
end
flag = size(x,1) == size(x,2) && all(all(abs(x - eye(size(x))) <= tol));
end