function Eqtn = myeqtn2symb(Eqtn)
% mysymb2eqtn  [Not a public function] Replace references to a variable array with sydney representation of variables.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Replace `x(:,10,t-1)` or `x(10,t-1)` with `x10m1`, etc.
% Replace `L(:,10,t-1)` or `L(10,t-1)` with `L10m1`, etc.
Eqtn = regexprep(Eqtn,'\<([xL])\((:,)?(\d+),t\)','$1$3');
Eqtn = regexprep(Eqtn,'\<([xL])\((:,)?(\d+),t\+0\)','$1$3');
Eqtn = regexprep(Eqtn,'\<([xL])\((:,)?(\d+),t\+(\d+)\)','$1$3p$4');
Eqtn = regexprep(Eqtn,'\<([xL])\((:,)?(\d+),t-(\d+)\)','$1$3m$4');

% Replace `g(10,:)` with `g10`.
Eqtn = regexprep(Eqtn,'\<g\((\d+),:\)','g$1');

end