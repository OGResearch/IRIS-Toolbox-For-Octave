function X = subsref(This,varargin)

X = [];
for i = 1 : length(This.Container)
    try
        x = subsref(This.Container{i},varargin{:});
        X = This.AggregationFunc(X,x);
    catch Err
        if This.Error
            rethrow(Err)
        else
            X = This.AggregationFunc(X,This.Catch);
        end
    end     
end

end