function G = splitgroup(G,GroupName)
% rmgroup  Split group with name GroupName into its components in group
% object G.
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

% Contributions of shocks or measurement variables?
switch G.type
    case 'shock'
        thisList = G.eList ;
        thisDescript = G.eDescript ;
    case 'measurement'
        thisList = G.yList ;
        thisDescript = G.yDescript ;
end

if ~iscell(GroupName)
    GroupName = {GroupName} ;
end

for iGroup = 1:numel(GroupName)
    ind = strcmpi(G.groupNames,GroupName{iGroup}) ;
    if any(ind)
        % Group exists, split
        splitNames = G.groupContents{ind} ;
        G.groupNames(ind) = '' ;
        G.groupContents(ind) = '' ;
        
        for iCont = 1:numel(splitNames)
            ind = strcmp(thisList,splitNames{iCont}) ;
            G = addgroup(G,thisDescript{ind},splitNames{iCont}) ;
        end
    elseif strcmpi('Other',GroupName{iGroup})
        % Split apart 'Other' group
        splitNames = G.otherGroup ;
        for iCont = 1:numel(splitNames)
            ind = strcmp(thisList,splitNames{iCont}) ;
            G = addgroup(G,thisDescript{ind},splitNames{iCont}) ;
        end
    else
        % Group does not exist, cannot remove
        utils.error('group:rmgroup','A group with that name does not exist and cannot be removed: %s',GroupName{iGroup}) ;
    end
end

end


