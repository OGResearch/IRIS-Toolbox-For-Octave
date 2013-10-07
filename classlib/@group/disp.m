function disp(This)
% disp  [Not a public function] Display method for group objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

ng = numel(This.groupNames) ;
fprintf(1,'Group object with %g groups. \n\n',ng) ;
if ~isempty(This.groupNames)
    switch This.type
        case 'shock'
            list = This.eList ;
            listDescript = This.eDescript ;
        case 'measurement'
            list = This.yList ;
            listDescript = This.yDescript ;
    end
    for iGroup = 1:ng
        fprintf(1,'%s:\n',This.groupNames{iGroup}) ;
        for iCont = 1:numel(This.groupContents{iGroup})
            xxDispName(This.groupContents{iGroup}{iCont}) ;
        end
    end
    if ~isempty(This.otherGroup)
        fprintf(1,'Other shocks: \n') ;
        for iCont = 1:numel(This.otherGroup)
            xxDispName(This.otherGroup{iCont}) ;
        end
    end
end

fprintf(1,'\n') ;
disp@userdataobj(This);
disp(' ');

    function xxDispName(contName)
        ind = strcmp(list,contName) ;
        fprintf(1,'    ') ;
        if ~isempty(listDescript{ind})
            fprintf(1,'%s ',listDescript{ind}) ;
        end
        fprintf(1,'[%s]\n',contName) ;
    end

end


