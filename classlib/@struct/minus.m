function this = minus(this,list)
    
%**************************************************************************
    
    if ischar(list)
        list = regexp(list,'\w+','match');
    elseif isstruct(list)
        list = fieldnames(list);
    end
    
    f = fieldnames(this).';
    c = struct2cell(this).';
    [fnew,index] = setdiff(f,list);
    this = cell2struct(c(index),fnew,2);
    
end
