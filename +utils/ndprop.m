function list = ndprop(obj)
% ndprop  [Not a public function] List of non-dependent properties of a non-char object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

if ischar(obj)
    mc = meta.class.fromName(obj);
else
    mc = metaclass(obj);
end

try
    index = ~[mc.PropertyList.Dependent];
    list = {mc.PropertyList(index).Name};
catch %#ok<CTCH>
    % Compatibility with 2010b.
    p = [mc.Properties{:}];
    index = ~[p.Dependent];
    list = {p.Name};
    list = list(index);
end

end