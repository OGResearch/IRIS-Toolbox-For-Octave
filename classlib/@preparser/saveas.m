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
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    FName; %#ok<VUNUS>
catch
    FName = [];
end

%--------------------------------------------------------------------------

% Substitute quoted strings back for the #(...) marks before
% saving the pre-parsed file.
C = restore(P.Code,P.Labels);

if ~isempty(FName)
    char2file(C,FName);
end

end