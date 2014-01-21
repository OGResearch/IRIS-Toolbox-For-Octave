function PP = myevalpprior(X,Pri)

PP = 0;
for i = find(Pri.priorindex)
    PP = PP + Pri.prior{i}(X(i));
    if ~isfinite(PP) || length(PP) ~= 1
        PP = -Inf;
        break
    end
end
PP = -PP;

end