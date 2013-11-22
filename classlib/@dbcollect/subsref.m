function X = subsref(This,S)

X = [];
for i = 1 : length(This.Container)
    try
        if length(S) == 1 && strcmp(S.type,'.') && ~isvarname(S.subs)
            x = dbeval(This.Container{i},S.subs);
        else
            x = subsref(This.Container{i},S);
        end
        X = This.AggregationFunc(X,x);
    catch Err
        if This.Error
            rethrow(Err);
        else
            X = This.AggregationFunc(X,This.Catch);
        end
    end     
end

end