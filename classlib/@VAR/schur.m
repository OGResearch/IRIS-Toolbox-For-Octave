function This = schur(This)
% schur  Compute and store triangular representation of VAR.
%
% Syntax
% =======
%
%     V = schur(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% Output arguments
% =================
%
% * `V` [ VAR ] - VAR object with the triangular representation matrices
% re-calculated.
%
% Description
% ============
%
% In most cases, you don't have to run the function `schur` as it is called
% from within `estimate` immediately after a new parameterisation is
% created.
%
% Example
% =======
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

[ny,p,nAlt] = size(This.A);
p = p / max(ny,1);

if p == 0
    This.T = zeros(ny,ny,nAlt);
    This.U = repmat(eye(ny),[1,1,nAlt]);
    This.eigval = zeros(1,ny,nAlt);
    return
end

A = zeros(ny*p,ny*p,nAlt);
for ialt = 1 : nAlt
    A(:,:,ialt) = [This.A(:,:,ialt);eye(ny*(p-1),ny*p)];
end

realSmall = getrealsmall();
This.U = nan(ny*p,ny*p,nAlt);
This.T = nan(ny*p,ny*p,nAlt);
This.eigval = nan(1,ny*p,nAlt);
for ialt = 1 : nAlt
    if any(any(isnan(A(:,:,ialt))))
        continue
    else
        [U,T] = schur(A(:,:,ialt));
        eigVal = ordeig(T);
        eigVal = eigVal(:)';
        unstable = abs(eigVal) > 1 + realSmall;
        unit = abs(abs(eigVal) - 1) <= realSmall;
        clusters = zeros(size(eigVal));
        clusters(unstable) = 2;
        clusters(unit) = 1;
        [This.U(:,:,ialt),This.T(:,:,ialt)] = ordschur(U,T,clusters);
        This.eigval(1,:,ialt) = ordeig(This.T(:,:,ialt)).';
    end
end

end