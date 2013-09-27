function S = mylogpoststruct(This)
% mylogpoststruct  [Not a public function] Prepare struct for mylogpost.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Prepackage options.
S = struct();
S.lowerBounds = This.lowerBounds(:);
S.upperBounds = This.upperBounds(:);
S.lowerBoundsPos = S.lowerBounds > -Inf;
S.upperBoundsPos = S.upperBounds < Inf;
S.lowerBounds = S.lowerBounds(S.lowerBoundsPos);
S.upperBounds = S.upperBounds(S.upperBoundsPos);
S.chkBounds = any(S.lowerBoundsPos) || any(S.upperBoundsPos);
S.isMinusLogPostFunc = isa(This.minusLogPostFunc,'function_handle');
if ~S.isMinusLogPostFunc
    S.priorInx = cellfun(@isfunc,This.logPriorFunc);
end

end