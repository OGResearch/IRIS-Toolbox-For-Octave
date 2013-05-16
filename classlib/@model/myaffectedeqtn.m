function Affected = myaffectedeqtn(This,iAlt,Select,Linear)
% myaffectedeqtn  [Not a public function] Equations affected by parameter changes since last system.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    Select; %#ok<VUNUS>
catch %#ok<CTCH>
    Select = true;
end

%--------------------------------------------------------------------------

Affected = true(size(This.eqtn));

% User forces all equations to be selected.
if ~Select
    return
end

% If deriv0 does not exist we must select all equations.
if ~any(any(This.deriv0.f(This.eqtntype <= 2,:)))
    return
end

% Changes in steady states and parameters.
changed = This.Assign(1,:,iAlt) ~= This.Assign0 ...
    & (~isnan(This.Assign(1,:,iAlt)) | ~isnan(This.Assign0));
if Linear
    % Only parameter changes matter in linear models.
    changed = changed & This.nametype == 4;
end

% Affected equations.
nname = length(This.name);
occur0 = This.occur(:,(This.tzero-1)*nname+(1:nname));
Affected = any(occur0(:,changed),2).';

end