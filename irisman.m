function irisman()
% irisman  Open IRIS Reference Manual PDF.
%
% Syntax
% =======
%
%     irisman
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

file = fullfile(irisroot(),'-help','IRIS_Man.pdf');
open(file);

end