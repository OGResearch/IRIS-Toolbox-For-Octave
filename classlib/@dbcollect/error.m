function This = error(This,Flag,Catch)

if Flag
    This.Error = true;
else
    This.Error = false;
    This.Catch = Catch;
end

end