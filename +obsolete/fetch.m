function this = fetch(this,n)
warning('iris:obsolete','FETCH(x,n) is deprecated syntax, and will not be supported in future versions. Use x(n) instead.');
this = subsref(this,struct('type','()','subs',{{n}}));
end