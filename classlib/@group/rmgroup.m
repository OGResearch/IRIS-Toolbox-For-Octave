function G = rmgroup(G,GroupName)
% rmgroup  Remove group from group object.
%
% Syntax
% =======
%
%     G = rmgroup(G,GroupName)
%
% Input arguments
% ================
%
% * `G` [ group ] - Group object.
%
% * `GroupName` [ char | cell ] - Group name.
%
% Output arguments
% =================
%
% * `G` [ group ] - Group object.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('G',@(x) isa(x,'group'));
pp.addRequired('GroupName',@(x) ischar(x) || iscell(x) );
pp.parse(G,GroupName);

if ~iscell(GroupName)
    GroupName = {GroupName} ;
end

for iGroup = 1:numel(GroupName)
    ind = strcmpi(G.groupNames,GroupName{iGroup}) ;
    if any(ind)
        % Group exists, remove
        G.groupNames(ind) = '' ;
        G.groupContents(ind) = '' ;
    elseif strcmpi('Other',GroupName{iGroup})
        utils.error('group:rmgroup','Cannot remove ''Other'' group.') ;
    else
        % Group does not exist, cannot remove
        utils.error('group:rmgroup','A group with that name does not exist and cannot be removed: %s',GroupName{iGroup}) ;
    end
end

end


