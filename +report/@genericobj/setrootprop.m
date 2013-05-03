function X = setrootprop(This,Prop,Val)
% root  [Not a public funtion ] Set property value in root report object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

X = root(This);
X.(Prop) = Val;

end