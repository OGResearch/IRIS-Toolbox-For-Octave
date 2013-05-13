function [Obj,L,PP,SP] = mylogpost(This,P,S)
% mylogpost  Evalute posterior density for given parameters.
% This is a subfunction, and not a nested function, so that we can later
% implement a parfor loop (parfor does not work with nested functions).
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team & Troy Matheson.

%--------------------------------------------------------------------------

Obj = 0;
L = 0;
PP = 0;
SP = 0;

if ~S.chkBounds || ...
        (all(P(S.lowerBoundsPos) >= S.lowerBounds) ...
        && all(P(S.upperBoundsPos) <= S.upperBounds))
    if S.isMinusLogPostFunc
        % Evaluate log posterior.
        [Obj,L,PP,SP] = ...
            This.minusLogPostFunc(P,This.minusLogPostFuncArgs{:});
        Obj = -Obj;
        L = -L;
        PP = -PP;
        SP = -SP;
    else
        % Evaluate parameter priors.
        for k = find(S.priorIndex)
            PP = PP + This.logPriorFunc{k}(P(k));
            if isinf(PP)
                Obj = Inf;
                return
            end
        end
        Obj = Obj + PP;
        % Evaluate minus log likelihood.
        L = This.minusLogLikFunc(P,This.minusLogLikFuncArgs{:});
        L = -L;
        Obj = Obj + L;
    end
else
    % Out of bounds.
    Obj = -Inf;
end

end