function flag = isa(this,cls)
% isa  [Not a public function] Implementation of isa() function replicating its
% functionality for Octave (before this bahavior is implemented in Octave)
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if is.matlab || ~isobject(this)
    flag = isa(this,cls);
else
    mc = metaclass(this);
    derivFrom = mc.SuperClassList;
    derivFromList = cell(1,numel(derivFrom));
    for ix = 1:numel(derivFrom)
        derivFromList{ix} = derivFrom{ix}.Name;
    end
    flag = any(strcmp(cls,[derivFromList,mc.Name]));
end

end