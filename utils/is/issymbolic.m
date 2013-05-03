function flag = issymbolic()
    flag = ~isempty(ver('symbolic'));
end