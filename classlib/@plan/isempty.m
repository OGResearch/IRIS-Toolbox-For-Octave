function flag = isempty(this,query)

switch query
    case 'tunes'
        flag = nnz(this.xAnchors) == 0 ...
            || nnz(this.nAnchorsReal) + nnz(this.nAnchorsImag) == 0;
    case 'cond'
        flag = nnz(this.cAnchors) == 0;
    case 'nonlin'
        flag = nnz(this.qAnchors) == 0;
    case 'range'
        flag = isempty(this.startDate) || isempty(this.endDate);
end

end