function [Obj,L,PP,SP,IsDiscarded] = mylogpost(This,P)
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

% `IsDiscarded` will return `true` if the current parameter vector violates
% the lower/upper bounds, or if it returns an ill-defined likelihood value.
IsDiscarded = false;

% Check lower/upper bounds first.
lowerInx = isfinite(This.lowerBounds);
upperInx = isfinite(This.upperBounds);
if any(lowerInx) || any(upperInx)
    % `P` is a column vector; `This.lowerBounds` and `This.upperBounds` are row
    % vectors and need to be tranposed.
    IsDiscarded = any(P(lowerInx) < This.lowerBounds(lowerInx).') ...
        || any(P(upperInx) > This.upperBounds(upperInx).');
end

if ~IsDiscarded
    if isa(This.minusLogPostFunc,'function_handle')
        % Evaluate log posterior.
        [Obj,L,PP,SP] = ...
            This.minusLogPostFunc(P,This.minusLogPostFuncArgs{:});
        % Discard draws that amount to an ill-defined value of the objective
        % function. Run the test *before* letting `Obj = -Obj` because the
        % assignment does not preserve complex numbers with zero imaginary part.
        IsDiscarded = ~isreal(Obj) || ~isfinite(Obj);
        Obj = -Obj;
        L = -L;
        PP = -PP;
        SP = -SP;
    else
        % Evaluate parameter priors.
        priorInx = cellfun(@isfunc,This.logPriorFunc);        
        for k = find(priorInx)
            PP = PP + This.logPriorFunc{k}(P(k));
            if isinf(PP)
                Obj = Inf;
                return
            end
        end
        Obj = Obj + PP;
        if isa(This.minusLogLikFunc,'function_handle')
            % Evaluate minus log likelihood.
            L = This.minusLogLikFunc(P,This.minusLogLikFuncArgs{:});
            L = -L;
            Obj = Obj + L;
        end
        IsDiscarded = ~isreal(Obj) || ~isfinite(Obj);
    end
end

if IsDiscarded
    Obj = -Inf;
end

end