function Ret = ifhg2(Yes,No)
% ifhg2  [Not a public function] Return a different value under HG2.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

isHg2 = false;
try %#ok<TRYNC>
    isHg2 = feature('UseHG2') || feature('HGUsingMATLABClasses');
end

if isHg2
    Ret = Yes;
else
    Ret = No;
end

end