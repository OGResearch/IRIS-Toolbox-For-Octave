function S = and(S1,S2)

if isempty(S1)
    S = S2;
    return
elseif isempty(S2)
    S = S1;
    return
end

S = dbfun(@horzcat,S1,S2);

end