function This = group(This,Grp)
% group  Retrieve VAR object from panel VAR for specified group of data.
%
% Syntax
% =======
%
%     V = group(V,Grp)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - Panel VAR object estimated on multiple groups of data.
%
% * `Grp` [ char ] - Requested group name; must be one of the names
% specified when the panel VAR object was constructed using the function
% [`VAR`](VAR/VAR).
%
% Output arguments
% =================
%
% * `V` [ VAR ] - VAR object for the `K`-th group of data.
%
% Description
% ============
%
% Example
% ========
%
% Create and estimate a panel VAR for three variables, `x`, `y`, `z`, and
% three countries, `US`, `EU`, `JA`. Then, retrieve a plain VAR for an
% individual country.
%
%     v = VAR({'x','y','z'},{'US','EU','JA'});
%     v = estimate(v,d,range,'fixedEffect=',true);
%     vi_us = group(v,'US');
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

pp = inputParser();
if ismatlab
pp.addRequired('V',@(x) isa(x,'VAR'));
pp.addRequired('Group',@(x) ischar(x) || is.numericscalar(x) || islogical(x));
pp.parse(This,Grp);
else
pp = pp.addRequired('V',@(x) isa(x,'VAR'));
pp = pp.addRequired('Group',@(x) ischar(x) || is.numericscalar(x) || islogical(x));
pp = pp.parse(This,Grp);
end

%--------------------------------------------------------------------------

if ischar(Grp)
    Grp = strcmp(Grp,This.GroupNames);
    if ~any(Grp)
    utils.error('VAR', ...
        'This group name does not exist in the %s object : ''%s''.', ...
        class(This),Grp);
    end
end

This = group@varobj(This,Grp);
This.K = This.K(:,Grp,:);

end