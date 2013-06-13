function this = diff(this,wrt,mode)

if ischar(wrt)
    wrt = regexp(wrt,'\w+','match');
end

nwrt = length(wrt);

if nwrt == 0
    this = [];
    return
end 

if nwrt == 1 && ~exist('mode','var')
    mode = 1;
end

if mode == 1
    % Create one function that returns an array of derivatives.
    this = mydiff(this,wrt);
    % Handle special case when there is no occurence of any of the `wrt`
    % variables in the expression, and a scalar zero is returned.
    if nwrt > 1 && isempty(this.func) && isequal(this.args,0)
        this.args = false(nwrt,1);
    else
        this = reduce(this);
    end
else
    % Create cell array of functions.
    n = length(wrt);
    z = mydiff(this,wrt);
    this = cell(1,n);
    for i = 1 : n
        this{i} = reduce(z,i);
    end
end

end