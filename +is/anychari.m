function Flag = anychari(X,List)
% anychari  Match a string against a list, case insensitive.
%
% Syntax
% =======
%
%     Flag = is.anychari(X,List)
%
% Input arguments
% ================
%
% * `X` [ char ] - Input string that will be matched against the `List`.
%
% * `List` [ cellstr ] - List of strings.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if the input string `X` equals at
% least one of the strings in the `List`, case insensitive.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = ischar(X) && any(strcmpi(X,List));

end