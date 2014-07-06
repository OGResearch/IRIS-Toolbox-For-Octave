function X = hg2(Yes,No)
% hg2  [Not a public function] Detect HG2 and implement a switch.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    Yes; %#ok<VUNUS>
catch
    Yes = true;
end

try
    No; %#ok<VUNUS>
catch
    No = false;
end

%--------------------------------------------------------------------------

isHg2 = false;
try %#ok<TRYNC>
    isHg2 = feature('UseHG2') || feature('HGUsingMATLABClasses');
end

if isHg2
    X = Yes;
else
    X = No;
end

end