function [This,DatFitted] = myassignest(This,S,ILoop,Opt)
% myassignest  [Not a public function] Assign estimated coefficient to VAR object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

A = S.A;
K = S.K;
G = S.G;
Omg = S.Omg;
Sgm = S.Sgm;
ci = S.ci;
resid = S.resid;
ny = size(A,1);
ng = size(G,2);
nGrp = max(1,length(This.GroupNames));
rep = ones(1,nGrp);

p = S.order; 
if Opt.diff
    p = p - 1;
end

if Opt.constant
    if size(K,2) == 1 && nGrp > 1
        % No fixed effect in panel regression; repeat the estimated constant vector
        % for all groups.
        K = K(:,rep);
    end
else
    K = zeros(ny,nGrp);
end

% Add the user-imposed mean to the VAR process.
if ~isempty(Opt.mean)
    m = Opt.mean;
    if nGrp > 1
        m = m(:,rep);
    end
    K = K + (eye(ny) - sum(reshape(A,ny,ny,p),3))*m;
end

J = S.J;
nx = length(This.XNames);
nGrp = max(1,length(This.GroupNames));
if size(J,2) == nx && nGrp > 1
    % No fixed effect in panel regression; repeat the estimated coefficient
    % matrices for all groups.
    J = repmat(J,1,nGrp);
end

% Convert VEC to co-integrated VAR.
if Opt.diff
    % Add the constant from the co-integrating vector to the constant vector.
    if ng > 0
        L = G*ci(:,1);
        if nGrp > 1
            L = L(:,rep);
        end
        K = K + L;
    end
    A = reshape(A,ny,ny,p);
    A = polyn.prod(A,cat(3,eye(ny),-eye(ny)));
    A = polyn.sum(A,eye(ny)+G*ci(:,2:end));
    p = p + 1;
    A = reshape(A,ny,ny*p);
end

This.A(:,:,ILoop) = A;
This.K(:,:,ILoop) = K;
This.J(:,:,ILoop) = J;
This.G(:,:,ILoop) = G;
This.Omega(:,:,ILoop) = Omg;
This.Sigma(:,:,ILoop) = Sgm;

fitted = all(~isnan(resid),1);
fitted = reshape(fitted,length(fitted)/nGrp,nGrp).';
fitted(:,end-p+1:end,:) = [];
This.Fitted(:,:,ILoop) = fitted;

DatFitted = cell(nGrp,1);
for iGrp = 1 : nGrp
    iFitted = fitted(iGrp,:);
    DatFitted{iGrp} = This.Range(iFitted);
end

end
