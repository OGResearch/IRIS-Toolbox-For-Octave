function disp(This)
% disp  [Not a public function] Display method for grouping objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(This)
    fprintf('\tempty grouping object\n');
else
    isOther = ~isempty(This.otherContents) ;
    nGroup = length(This.groupNames) ;
    if isOther
        nGroup = nGroup + 1 ;
    end
    
    fprintf(1,'\t%s grouping object: [%g] group(s)\n',This.type,nGroup) ;
end

disp@userdataobj(This);
disp(' ');

end


