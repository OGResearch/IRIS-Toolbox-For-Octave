function ch = mychar(this)
if is.func(this)
    ch = func2str(this);
else
    ch = char(this);
end