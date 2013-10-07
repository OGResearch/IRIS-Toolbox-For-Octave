function C = ellipsis(C,N)

if iscellstr(C)
    for i = 1 : numel(C)
        C{i} = strfun.ellipsis(C{i},N);
    end
    return
end

if length(C) > N
    C = [C(1:N-3),'...'];
end
C = sprintf('%-*s',N,C);

end