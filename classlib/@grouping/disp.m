function disp(This)
% disp  [Not a public function] Display method for grouping objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(This)
    if isempty(This.type)
        fprintf('\tempty grouping object\n');
    else
        fprintf('\tempty %s grouping object\n',This.type);
    end
else
    isOther = any(This.otherContents) ;
    nGroup = length(This.groupNames) + double(isOther) ;
    fprintf('\t%s grouping object: [%g] group(s)\n',This.type,nGroup) ;
end

if ~isempty(This.type)
    
    names = 'empty';
    if ~isempty(This.list)
        names = strfun.displist(This.list);
    end
    fprintf('\t%s names: %s\n',This.type,names);
    
    if ~isempty(This.groupNames)
        names = This.groupNames;
        if any(This.otherContents)
            names = [names,This.otherName];
        end
        names = strfun.displist(names);
    else
        names = 'empty';
    end
    fprintf('\tgroup names: %s',names);
    fprintf('\n');
end

disp@userdataobj(This);
disp(' ');

end


