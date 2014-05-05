function Cov = mycovmatrix(This,Alt)

try
    Alt; %#ok<VUNUS>
catch
    Alt = ':';
end

%--------------------------------------------------------------------------

ny = size(This.A,1);

varVec = This.Std(1,Alt) .^ 2;
varVec = permute(varVec(:),[2,3,1]);
n3 = length(varVec);

q = min(ny,This.Rank);
Cov = eye(ny);
Cov(:,q+1:end) = 0;
Cov = Cov(:,:,ones(1,n3));
Cov = bsxfun(@times,Cov,varVec);

end