function this = mystruct2obj(this,s)
% MYSTRUCT2OBJ  [Not a public function] Copy structure fields to object properties.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

% List of non-dependent object properties.
prop = utils.ndprop(class(this));

nprop = length(prop);
for i = 1 : nprop
    try
        this.(prop{i}) = s.(prop{i});
    catch %#ok<CTCH>
        % Properties `assign`, `assign0`, `expand`, and
        % `refresh` are capitalised in new class syntax.
        % Handle structs that have lower-case property names.
        try %#ok<TRYNC>
            this.(prop{i}) = s.(lower(prop{i}));
        end
    end
end

end