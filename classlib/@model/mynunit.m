function NUnit = mynunit(This,IAlt)
% mynunit  [Not a public function]  Number of unit roots in a parameterisation.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(This.eigval)
    NUnit = 0;
    return
end

eigValTol = This.Tolerance(1);
eigVal = This.eigval(1,:,min(IAlt,end));
if any(isnan(eigVal(:)))
    NUnit = NaN;
    return
end

absEigVal = abs(eigVal);
NUnit = sum(abs(absEigVal - 1) <= eigValTol);

end