function POS = findlast(X)
if isempty(X)
    POS = 0;
elseif isnumeric(X)
    POS = max([0,find(any(any(X ~= 0,3),1),1,'last')]);
else
    POS = max([0,find(any(any(X,3),1),1,'last')]);
end
end