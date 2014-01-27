function This = mystruct2obj(This,S)
% mystruct2obj  [Not a public function] Copy structure fields to object properties.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% List of non-dependent object properties.
prop = utils.ndprop(class(This));

nProp = length(prop);
for i = 1 : nProp
    try
        This.(prop{i}) = S.(prop{i});
    catch %#ok<CTCH>
        try %#ok<TRYNC>
            This.(prop{i}) = S.(lower(prop{i}));
        end
    end
end

end