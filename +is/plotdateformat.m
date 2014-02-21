function Flag = plotdateformat(X)
% plotdateformat  [Not a public function] True for valid plot date format option.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = ischar(X) ...
    || (isstruct(X) && all(isfield(X,{'yy','hh','qq','bb','mm','ww'})));

end