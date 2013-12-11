function List = fieldnames(This)

List = {};
for i = 1 : length(This.Container)
    List = union(List,fieldnames(This.Container{i}));    
end

end