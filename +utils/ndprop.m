function List = ndprop(This)
% ndprop  [Not a public function] List of non-dependent properties of a non-char object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ischar(This)
    mc = meta.class.fromName(This);
else
    mc = metaclass(This);
end

try
    inx = ~[mc.PropertyList.Dependent];
    List = {mc.PropertyList(inx).Name};
catch %#ok<CTCH>
    try % Compatibility with 2010b.
        p = [mc.Properties{:}];
        inx = ~[p.Dependent];
        List = {p.Name};
        List = List(inx);
    catch % Compatibility with Octave.
        List = [];
        prList = mc.PropertyList;
        for px = 1:length(prList)
          if ~prList{px}.Dependent
            List = [List, {prList{px}.Name}];
          end
        end
    end
end

end