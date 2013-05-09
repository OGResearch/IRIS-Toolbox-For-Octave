function x = subsref(this,varargin)

s = varargin{1};
ispreserved = strcmp(s(1).type,'()') && length(s(1).subs) >= 2;
if ispreserved
    rownames = this.rownames;
    colnames = this.colnames;
    s1 = s(1);
    s1.subs = s1.subs(1);
    rownames = subsref(rownames,s1);
    s2 = s(1);
    s2.subs = s2.subs(2);
    colnames = subsref(colnames,s2);
end
x = double(this);
x = subsref(x,s,varargin{2:end});
if ispreserved
    x = namedmat(x,rownames,colnames);
end

end
