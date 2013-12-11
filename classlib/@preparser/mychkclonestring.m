function Flag = mychkclonestring(C)
% mychkclonestring  [Not a public function] Validate clone string.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = ~isempty(C) && (isletter(C(1)) || C(1) == '?') ...
    && isempty(regexp(C,'[^\w\?]','once')) ...
    && length(strfind(C,'?')) == 1;

end