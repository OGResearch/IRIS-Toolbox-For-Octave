function Cov = mycovmatrix(This,Alt)

try
    Alt; %#ok<VUNUS>
catch
    Alt = ':';
end

%--------------------------------------------------------------------------

ny = size(This.A,1);

varVec = This.std(1,Alt) .^ 2;
varVec = permute(varVec(:),[2,3,1]);
n3 = length(varVec);

Cov = eye(ny);
Cov = Cov(:,:,ones(1,n3));
Cov = bsxfun(@times,Cov,varVec);

end