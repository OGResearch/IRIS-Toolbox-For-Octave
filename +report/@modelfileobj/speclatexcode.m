function [C,Temps] = speclatexcode(This)
% speclatexcode  [Not a public function] \LaTeX\ code for modelfile object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Do not do verbatim because we use \verb direct in the typeset model file.
This.options.verbatim = false;
This.options.centering = false;
This.userinput = printmodelfile(This);
[C,Temps] = speclatexcode@report.userinputobj(This);

end
