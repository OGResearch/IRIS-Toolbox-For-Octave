function flag = iscellstrwithnans(x)
    flag = ...
        all(cellfun(@(x) ischar(x) || isequalwithequalnans(x,NaN),x(:)));
end