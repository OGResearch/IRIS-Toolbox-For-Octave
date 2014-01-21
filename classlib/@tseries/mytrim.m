function X = mytrim(X)
% mytrim  [Not a public function] Remove leading and trailing NaNs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(X.data)
    return
end

if isreal(X.data)
    testForNan = @isnan;
else
    testForNan = @(x) isnan(real(x)) & isnan(imag(x));
end

if ~any(any(testForNan(X.data([1,end],:))))
    return
end

nanInx = all(testForNan(X.data(:,:)),2);
newSize = size(X.data);
if all(nanInx)
    X.start = NaN;
    newSize(1) = 0;
    X.data = zeros(newSize);
else
    first = find(~nanInx,1);
    last = find(~nanInx,1,'last');
    X.data = X.data(first:last,:);
    newSize(1) = last - first + 1;
    X.data = reshape(X.data,newSize);
    X.start = X.start + first - 1;
end

end