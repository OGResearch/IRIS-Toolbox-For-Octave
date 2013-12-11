function Val = getrootprop(This,Prop)
% root  [Not a public funtion ] Get property value from root report object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

X = root(This);
Val = X.(Prop);

end