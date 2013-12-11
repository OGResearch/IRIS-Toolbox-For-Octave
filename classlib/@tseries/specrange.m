function range = specrange(this,range)

if isempty(range)
    return
end

if isequal(range,':')
    range = this.start + (0 : size(this.data,1)-1);
    return
end

if isinf(range(1))
    startdate = this.start;
else
    startdate = range(1);
end

if isinf(range(end))
    enddate = this.start + size(this.data,1) - 1;
else
    enddate = range(end);
end

range = startdate : enddate;

end