function L = eval(This,varargin)

if isstruct(varargin{1})
    [X,P] = data4eval(This,varargin{1:3});
else
    X = varargin{1};
    P = varargin{2};
end

L = This.minusLogLikFunc(X,P);

end

