function Stdcorr = cov2stdcorr(Omg,varargin)
% cov2stdcorr  [Not a public function] Convert cov matrix to stdcorr vector.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

[~,ne,nPer,nAlt] = size(Omg);
Omg = Omg(:,:,:);

if ne > 0
    inx = tril(ones(ne),-1) == 1;
else
    inx = [];
end

R = covfun.cov2corr(Omg);
n = ne + ne*(ne-1)/2;
Stdcorr = nan(n,nPer*nAlt);
for i = 1 : nPer*nAlt
    Stdcorr(1:ne,i) = sqrt(diag(Omg(:,:,i)));
    Stdcorr(ne+1:end,i) = R(inx);
end

Stdcorr = reshape(Stdcorr,[n,nPer,nAlt]);

end
