function detail(This)
% detail  Details of a grouping object.
%
% Syntax
% =======
%
%     detail(G)
%
% Input arguments
% ================
%
% * `G` [ grouping ] - Grouping object.
%
% Description
% ============
%
% Example
% ========

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

strfun.loosespace();

if isempty(This)
    return
end

isOther = any(This.otherContents) ;
groupNames = This.groupNames ;
groupContents = This.groupContents ;
if isOther
    groupNames = [groupNames,{This.otherName}] ;
    groupContents = [groupContents,{This.otherContents}] ;
end
nGroup = length(groupNames) ;

for iGroup = 1:nGroup
    fprintf('\t+Group ''%s'':\n',groupNames{iGroup}) ;
    list = This.list(groupContents{iGroup}) ;
    descript = This.descript(groupContents{iGroup}) ;
    for iCont = 1:numel(list)
        iName = list{iCont} ;
        iDescript = descript{iCont} ;
        doDispName() ;
    end
end

strfun.loosespace();


% Nested functions...


    function doDispName()
        fprintf('\t\t') ;
        fprintf('+%s',iName);
        if ~isempty(iDescript)
            fprintf(' ''%s''',iDescript) ;
        end
        fprintf('\n');
    end


end


