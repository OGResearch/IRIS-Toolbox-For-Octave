function Y = linex(X,A,B,varargin)

if length(A) == 1
    A = A*ones(size(X));
end

if length(B) == 1
    B = B*ones(size(X));
end

azero = A == 0;
bzero = B == 0;
xpos = X > 0;
xneg = X < 0;

if isempty(varargin)
    Y = X;
    inx = ~azero & xneg;
    Y(inx) = (exp(A(inx).*X(inx)) - 1) ./ A(inx);
    inx = ~bzero & xpos;
    Y(inx) = (exp(B(inx).*X(inx)) - 1) ./ B(inx);
    return
end

if length(varargin) == 1 && isequal(varargin{1},'diff')
    Y = true;
    return
end

if length(varargin) == 2 ...
        && isequal(varargin{1},'diff') ...
        && isequal(varargin{2},1)
    Y = ones(size(X));
    Y(xneg) = exp(A(xneg).*X(xneg));
    Y(xpos) = exp(B(xpos).*X(xpos));
    return
end

end