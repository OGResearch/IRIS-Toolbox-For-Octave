function [PStar,ObjStar,PCov,Hess] = estimate(This,Data,Range,E,varargin)

estOpt = passvalopt('likfunc.estimate',varargin{:});

X = data4eval(This,Data,Range);

pri = myparamstruct(This,X,E);

[~,PStar,ObjStar,PCov,Hess] = myestimate(This,X,pri,estOpt,[]);

end