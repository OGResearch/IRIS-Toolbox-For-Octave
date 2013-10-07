function X = myreshape(This,XX)
% myreshape  [Not a public function] Reshape transition vector data for output.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

s = size(XX);
XX = XX(:,:,:);
nPer = size(XX,2);

realId = real([This.solutionid{2}]);
imagId = imag([This.solutionid{2}]);
maxLag = -min(imagId);
offset = sum(This.nametype == 1);

X = nan(sum(This.nametype == 2),nPer+maxLag,size(XX,3));
for i = find(imagId == 0)
    X(realId(i)-offset,maxLag+1:end,:) = XX(i,:,:);
    if any(imagId(realId == realId(i)) < 0)
        for j = 1 : maxLag
            pos = realId == realId(i) & imagId == -j;
            if any(pos)
                X(realId(i)-offset,maxLag+1-j,:) = XX(pos,1,:);
            end
        end
    end
end

if length(s) > 3
    X = reshape(X,[size(X,1),size(X,2),s(3:end)]);
end

end