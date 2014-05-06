function This = group(This,Grp)
% group  [Not a public function] Retrieve varobj object from a panel varobj for specified group of data.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

pp = inputParser();
if ismatlab
pp.addRequired('V',@(x) isa(x,'VAR'));
pp.addRequired('Group',@(x) ...
    ischar(x) || is.numericscalar(x) || islogical(Grp));
pp.parse(This,Grp);
else
pp = pp.addRequired('V',@(x) isa(x,'VAR'));
pp = pp.addRequired('Group',@(x) ...
    ischar(x) || is.numericscalar(x) || islogical(Grp));
pp = pp.parse(This,Grp);
end

%--------------------------------------------------------------------------

if ischar(Grp)
    Grp = strcmp(Grp,This.GroupNames);
end
This.GroupNames = {};
This.Fitted = This.Fitted(Grp,:,:);

end