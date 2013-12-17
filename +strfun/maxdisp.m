function c = maxdisp(c,n)

if ~exist('n','var')
    n = 40;
end

if length(c) > n
    c = c(1:n);
    c(end-2:end) = '...';
end

end