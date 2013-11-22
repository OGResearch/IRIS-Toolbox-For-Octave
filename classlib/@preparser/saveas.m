function C = saveas(P,FName)
% saveas  Save preparsed file.
%
% Syntax
% =======
%
%     saveas(P,FName)
%
% Input arguments
% ================
%
% * `P` [ preparser ] - Preparser object (preparsed file).
%
% * `FName` [ char ] - File name under which the preparsed code will be
% saved.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Substitute quoted strings back for the #(...) marks before
% saving the pre-parsed file.
C = restore(P.code,P.labels);

if exist('FName','var') && ~isempty(FName)
    char2file(C,FName);
end

end