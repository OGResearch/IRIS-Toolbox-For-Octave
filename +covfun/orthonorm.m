function [B,u] = orthonorm(Omega,q,std,e)
% orthonorm  Convert reduced-form residuals to orthonormal residuals.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if nargin < 2
    q = Inf;
end

if nargin < 3
    std = 1;
end

%**************************************************************************

ny = size(Omega,1);
nalt = size(Omega,3);
if q > ny
    q = ny;
end

B = zeros([ny,ny,nalt]);
V = zeros([ny,q,nalt]);
s = zeros([q,nalt]);
Q = zeros([ny,ny,nalt]);
for iloop = 1 : nalt
    [V1,S,V2] = svd(Omega(:,:,iloop));
    V1 = V1(:,1:q);
    V2 = V2(:,1:q);
    V(:,:,iloop) = (V1+V2)/2;
    s(:,iloop) = sqrt(diag(S(1:q,1:q))) / std;
    Z = diag(s(:,iloop));
    B(:,1:q,iloop) = V(:,:,iloop)*Z;
    % Q is used to convert residuals.
    Q(1:q,:,iloop) = diag(1./s(:,iloop))*V(:,:,iloop)';
end

if nargin > 3 && nargout > 1 && ~isempty(e)
    nper = size(e,2);
    ndata = size(e,3);
    if ndata < nalt
        e(:,:,end+1:nalt) = e(:,:,ndata*ones([1,nalt-ndata]));
    end
    nloop = max([nalt,ndata]);
    u = zeros([ny,nper,nloop]);
    for iloop = 1 : nloop
        if iloop <= nalt
            Qi = Q(1:q,:,iloop);
        end
        if iloop <= ndata
            ei = e(:,:,iloop);
        end
        u(1:q,:,iloop) = Qi*ei;
    end
else
    u = [];
end

end
