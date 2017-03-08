function display(this)
% disp  [Not a public function] DISP implementation for userdataobj.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

if false % ##### MOSW
    if isequal(get(0,'FormatSpacing'),'compact')
        disp([inputname(1),' =']);
    else
        disp(' ')
        disp([inputname(1),' =']);
        disp(' ');
    end
else
    disp(' ')
    disp([inputname(1),' =']);
    disp(' ');
end
disp(this);

end