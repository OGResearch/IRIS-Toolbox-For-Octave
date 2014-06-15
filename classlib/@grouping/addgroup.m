function This = addgroup(This,GroupName,GroupContentsList)
% addgroup  Add measurement variable group or shock group to grouping object.
%
% Syntax
% =======
%
%     G = addgroup(G,GroupName,GroupContents)
%
% Input arguments
% ================
%
% * `G` [ grouping ] - Grouping object.
%
% * `GroupName` [ char ] - Group name.
%
% * `GroupContents` [ char | cell | `Inf` ] - Names of shocks or
% measurement variables to be included in the new group; `GroupContents`
% can also be regular expressions; `Inf` the group will contain all shocks
% or measurement variables not included in any existing group.
%
% Output arguments
% =================
%
% * `G` [ grouping ] - Grouping object with the new group.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

pp = inputParser() ;
if ismatlab
pp.addRequired('G',@(x) isa(x,'grouping')) ;
pp.addRequired('GroupName',@(x) ~isempty(x) && ischar(x)) ;
pp.addRequired('GroupContents',@(x) ~isempty(x) ...
    && (iscell(x) || ischar(x)) || isequal(x,Inf) ) ;
pp.parse(This,GroupName,GroupContentsList) ;
else
pp = pp.addRequired('G',@(x) isa(x,'grouping')) ;
pp = pp.addRequired('GroupName',@(x) ~isempty(x) && ischar(x)) ;
pp = pp.addRequired('GroupContents',@(x) ~isempty(x) ...
    && (iscell(x) || ischar(x)) || isequal(x,Inf) ) ;
pp = pp.parse(This,GroupName,GroupContentsList) ;
end

if ischar(GroupContentsList)
    GroupContentsList = regexp(GroupContentsList,'[^ ,;]+','match') ;
end

%--------------------------------------------------------------------------

nList = length(This.list) ;
valid = true(size(GroupContentsList)) ;
if isequal(GroupContentsList,Inf)
    groupContents = This.otherContents ;
    if isempty(groupContents)
        groupContents = true(nList,1) ;
    end
else
    groupContents = false(1,nList) ;
    for i = 1 : length(GroupContentsList)
        ind = strfun.matchindex(This.list,GroupContentsList{i}) ;
        valid(i) = any(ind);
        groupContents = groupContents | ind ;
    end
    groupContents = groupContents.';
end

doChkName() ;

ind = strcmpi(This.groupNames,GroupName) ;
if any(ind)
    % Group already exists, modify
    This.groupNames{ind} = GroupName ;
    This.groupContents{ind} = groupContents ;
else
    % Add new group
    This.groupNames = [This.groupNames, GroupName] ;
    This.groupContents = [This.groupContents, {groupContents}] ;
end

doChkUnique() ;


    function doChkUnique()
        multiple = sum(double([This.groupContents{:}]),2) > 1 ;
        if any(multiple)
            utils.error('grouping', ...
                ['This ',This.type,' name is assigned to ', ...
                'multiple groups: ''%s''.'], ...
                This.list{multiple}) ;
        end
    end


    function doChkName()
        if any(~valid)
            utils.error('grouping', ...
                ['This is not a valid %s name ', ...
                'in the grouping object: ''%s''.'], ...
                This.type,GroupContentsList{~valid}) ;
        end
    end


end
