function Range = specrange(This,Range)

if isempty(Range)
    return
end

if isequal(Range,':')
    Range = This.start + (0 : size(This.data,1)-1);
    return
end

if isinf(Range(1))
    startDate = This.start;
else
    startDate = Range(1);
end

if isinf(Range(end))
    endDate = This.start + size(This.data,1) - 1;
else
    endDate = Range(end);
end

Range = startDate : endDate;

end