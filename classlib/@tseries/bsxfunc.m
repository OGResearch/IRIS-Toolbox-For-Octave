function X = bsxfunc(FUNC,X,Y)

isxtseries = isa(X,'tseries');
isytseries = isa(Y,'tseries');

if isxtseries
    [xdata,xrange] = rangedata(X);
else
    xdata = X;
end

if isytseries
    ydata = rangedata(Y,xrange);
else
    ydata = Y;
end


DATA = bsxfunc(FUNC,DATA,Y);

if is.tseries
    X.data = DATA;
else
    X = DATA;
end

end