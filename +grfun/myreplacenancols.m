function X = myreplacenancols(X,Replace)
% myreplacenancols [Not a public function] Replace all-NaN columns with a specified value (Inf).
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

s = size(X);
X = X(:,:);
allNaNInx = all(isnan(X),1);
X(:,allNaNInx) = Replace;
if length(s) > 2
    X = reshape(X,s);
end

end
