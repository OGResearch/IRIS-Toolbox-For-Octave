function [Obj,L,PP,SP,IsDiscarded] = mylogpost(This,P)
% mylogpost  Evalute posterior density for given parameters.
% This is a subfunction, and not a nested function, so that we can later
% implement a parfor loop (parfor does not work with nested functions).
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team & Troy Matheson.

%--------------------------------------------------------------------------

Obj = 0;
L = 0;
PP = 0;
SP = 0;

% `IsDiscarded` will return `true` if the current parameter vector violates
% the lower/upper bounds, or if it returns an ill-defined likelihood value.
IsDiscarded = false;

% Check lower/upper bounds first.
lowerInx = isfinite(This.LowerBounds);
upperInx = isfinite(This.UpperBounds);
if any(lowerInx) || any(upperInx)
    % `P` is a column vector; `This.LowerBounds` and `This.UpperBounds` are row
    % vectors and need to be tranposed.
    IsDiscarded = any(P(lowerInx) < This.LowerBounds(lowerInx).') ...
        || any(P(upperInx) > This.UpperBounds(upperInx).');
end

if ~IsDiscarded
    if isa(This.MinusLogPostFunc,'function_handle')
        % Evaluate log posterior.
        [Obj,L,PP,SP] = ...
            This.MinusLogPostFunc(P,This.MinusLogPostFuncArgs{:});
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
        priorInx = cellfun(@is.func,This.LogPriorFunc);        
        for k = find(priorInx)
            PP = PP + This.LogPriorFunc{k}(P(k));
            if isinf(PP)
                Obj = Inf;
                return
            end
        end
        Obj = Obj + PP;
        if isa(This.MinusLogLikFunc,'function_handle')
            % Evaluate minus log likelihood.
            L = This.MinusLogLikFunc(P,This.MinusLogLikFuncArgs{:});
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