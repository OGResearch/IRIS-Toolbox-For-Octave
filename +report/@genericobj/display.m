function display(This)
% disp  Display the structure of a report object.
%
% Help provided in +report/disp.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

strfun.loosespace();
disp([inputname(1),' =']);
strfun.loosespace();
disp(This);

end
