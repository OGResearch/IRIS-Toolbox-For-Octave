function C = speclatexcode(This)
% speclatexcode  [Not a public function] \LaTeX\ code for include objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Read in the user file.
This.userinput = file2char(This.filename,'char',This.options.lines);

% Convert end-of-lines.
This.userinput = strfun.converteols(This.userinput);

C = speclatexcode@report.userinputobj(This);

end
