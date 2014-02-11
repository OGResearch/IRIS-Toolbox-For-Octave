function eqtn = myeqtn2symb(eqtn)
% mysymb2eqtn  [Not a public function] Replace references to a variable array with sydney representation of variables.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Replace x(:,10,t-1) or x(10,t-1) with x10m1, etc.
% Replace L(:,10) or L(10) with L10.
eqtn = regexprep(eqtn,'x\((:,)?(\d+),t\)','x$2');
eqtn = regexprep(eqtn,'x\((:,)?(\d+),t\+0\)','x$2');
eqtn = regexprep(eqtn,'x\((:,)?(\d+),t\+(\d+)\)','x$2p$3');
eqtn = regexprep(eqtn,'x\((:,)?(\d+),t-(\d+)\)','x$2m$3');
eqtn = regexprep(eqtn,'L\((:,)?(\d+)\)','L$2');
eqtn = regexprep(eqtn,'g\((\d+),:\)','g$1');

end