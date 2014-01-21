function This = rmgroup(This,varargin)
% rmgroup  Remove group from grouping object.
%
% Syntax
% =======
%
%     G = rmgroup(G,GroupName1,GroupName2,...)
%
% Input arguments
% ================
%
% * `G` [ grouping ] - Grouping object.
%
% * `GroupName1`, `GroupName2`,... [ char ] - Names of groups that will be
% removed.
%
% Output arguments
% =================
%
% * `G` [ groupin ] - Grouping object.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

GroupName = varargin;

pp = inputParser();
pp.addRequired('G',@(x) isa(x,'grouping'));
pp.addRequired('GroupName',@iscellstr);
pp.parse(This,GroupName);

%--------------------------------------------------------------------------

nGroup = length(GroupName);
valid = true(1,nGroup);
for iGroup = 1:nGroup
    ind = strcmpi(This.groupNames,GroupName{iGroup}) ;
    if any(ind)
        % Group exists, remove
        This.groupNames(ind) = [] ;
        This.groupContents(ind) = [] ;
    elseif strcmpi(This.otherName,GroupName{iGroup})
        utils.error('grouping', ...
            'Cannot remove ''%s'' group.', ...
            This.otherName) ;
    else
        valid(iGroup) = false ;
    end
end

if any(~valid)
    utils.error('grouping', ...
        'This group name does not exist and cannot be removed: ''%s''.', ...
        GroupName{~valid});
end

end


