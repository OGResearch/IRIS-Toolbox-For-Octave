function Flag = matlab()
% matlab  [Not a public function] True if called from within Matlab.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = false;
try %#ok<TRYNC>
    x = ver('Matlab');
    if isstruct(x) && length(x) >= 1
        Flag = true;
    end
end

end