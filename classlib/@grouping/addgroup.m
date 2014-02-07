function This = addgroup(This,GroupName,GroupContentsList)
% addgroup  Add measurement variable or shock grouping to grouping object.
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
% * `GroupContents` [ char | cell ] - Names of shocks or measurement
% variables to be included in the new group; `GroupContents` can also be
% regular expressions.
%
% Output arguments
% =================
%
% * `G` [ grouping ] - Grouping object.
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
    && (iscell(x) || ischar(x)) ) ;
pp.parse(This,GroupName,GroupContentsList) ;
else
pp = pp.addRequired('G',@(x) isa(x,'grouping')) ;
pp = pp.addRequired('GroupName',@(x) ~isempty(x) && ischar(x)) ;
pp = pp.addRequired('GroupContents',@(x) ~isempty(x) ...
    && (iscell(x) || ischar(x)) ) ;
pp = pp.parse(This,GroupName,GroupContentsList) ;
end

if ischar(GroupContentsList)
    GroupContentsList = regexp(GroupContentsList,'[^ ,;]+','match') ;
end

%--------------------------------------------------------------------------

groupContents = false(size(This.list)) ;
valid = true(size(GroupContentsList)) ;
for i = 1 : length(GroupContentsList)
    ind = strfun.matchindex(This.list,GroupContentsList{i}) ;
    valid(i) = any(ind);
    groupContents = groupContents | ind;
end

doChkName() ;

groupContents = groupContents.';

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

