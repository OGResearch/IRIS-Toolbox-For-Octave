function loosespace()
% loosespace  Print a line break if spacing is set to loose.
%
% Syntax
% =======
%
%     strfun.loosespace()
%
% Description
% ============
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if false % ##### MOSW
    if ~strcmp(get(0,'FormatSpacing'),'compact')
       fprintf('\n');
    end
else
    fprintf('\n');
end
    
end