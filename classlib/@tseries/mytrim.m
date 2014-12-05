function This = mytrim(This)
% mytrim  [Not a public function] Remove leading and trailing NaNs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

This = mystamp(This);
if isempty(This.data)
    return
end

if isreal(This.data)
    testForNan = @isnan;
else
    testForNan = @(x) isnan(real(x)) & isnan(imag(x));
end

if ~any(any(testForNan(This.data([1,end],:))))
    return
end

nanInx = all(testForNan(This.data(:,:)),2);
newSize = size(This.data);
if all(nanInx)
    This.start = NaN;
    newSize(1) = 0;
    This.data = zeros(newSize);
else
    first = find(~nanInx,1);
    last = find(~nanInx,1,'last');
    This.data = This.data(first:last,:);
    newSize(1) = last - first + 1;
    This.data = reshape(This.data,newSize);
    This.start = This.start + first - 1;
end

end
