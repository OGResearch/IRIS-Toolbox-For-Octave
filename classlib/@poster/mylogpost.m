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

% Discard this draw if it violates lower or upper bounds.
isDiscarded = S.chkBounds && ...
    (any(P(S.lowerBoundsPos) < S.lowerBounds) ...
    || any(P(S.upperBoundsPos) > S.upperBounds));

if ~isDiscarded
    if S.isMinusLogPostFunc
        % Evaluate log posterior.
        [Obj,L,PP,SP] = ...
            This.minusLogPostFunc(P,This.minusLogPostFuncArgs{:});
        % Discard draws that amount to an ill-defined value of the objective
        % function. Run the test *before* letting `Obj = -Obj` because the
        % assignment does not preserve complex numbers with zero imaginary part.
        isDiscarded = ~isreal(Obj) || ~isfinite(Obj);
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
        isDiscarded = ~isreal(Obj) || ~isfinite(Obj);
    end
end

if isDiscarded
    Obj = -Inf;
end

end