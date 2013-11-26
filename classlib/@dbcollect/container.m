function X = container(This,Inx)

try
    Inx; %#ok<VUNUS>
catch %#ok<CTCH>
    Inx = ':';
end

X = This.Container{1,Inx};

end