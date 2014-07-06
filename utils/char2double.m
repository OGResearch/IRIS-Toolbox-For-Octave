function dbl = char2double(chr)

dbl = double(chr);

if ~ismatlab && any(dbl>127)
    dbl = dbl(:);
    ix = find(dbl>127);
    ix = ix(1:2:end-1);
    dbl(ix) = back2highCharCode([dbl(ix) dbl(ix+1)]);
    dbl(ix+1) = [];
    dbl = dbl';
end

end
