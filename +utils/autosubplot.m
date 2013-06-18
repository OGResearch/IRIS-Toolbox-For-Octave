function varargout = autosubplot(npanel)

x = ceil(sqrt(npanel));
if x*(x-1) >= npanel
    nrow = x;
    ncol = x-1;
else
    nrow = x;
    ncol = x;
end

if nrow <= 0 || ncol <= 0
    nrow = 0;
    ncol = 0;
end 

if nargout <= 1
    varargout{1} = [nrow,ncol];
else
    varargout = {nrow,ncol};
end

end