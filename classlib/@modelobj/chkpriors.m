function [Flag,BoundList,PriorList,NotFoundList] = chkpriors(M,E)
% chkpriors  Check consistency of priors and bounds with initial
% conditions.
%
% Syntax
% =======
%
%     Flag = chkpriors(M,E)
%     [Flag,InvalidBound,InvalidPrior,NotFound] = chkpriors(M,E)
%
% Input arguments
% ================
%
% * `M` [ struct ] - Model object.
%
% * `E` [ struct ] - Prior structure. See `model/estimate` for details.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if all parameters exist in the model
% object, and have initial values consistent with lower and upper bounds,
% and prior distributions.
%
% * `InvalidBound` [ cellstr ] - Cell array of parameters whose initial
% values are inconsistent with lower or upper bounds.
%
% * `InvalidPrior` [ cellstr ] - Cell array of parameters whose initial
% values are inconsistent with priors.
%
% * `NotFound` [ cellstr ] - Cell array of parameters that do not exist in
% the model object `M`.
%
% Options
% ========
%

% Validate input arguments
pp = inputParser() ;
pp.addRequired('E',@isstruct) ;
pp.parse(E) ;

% Check consistency by looping over parameters
pnames = fieldnames(E) ;
np = numel(pnames) ;

validPrior = true(1,np) ;
validBound = true(1,np) ;

[assignPos,stdcorrPos] = mynameposition(M,pnames);
found = ~isnan(assignPos) | ~isnan(stdcorrPos);

for iname = find(found)
    
    param = E.(pnames{iname}) ;
    if isnan(param{1})
        % use initial condition from model object
        if ~isnan(assignPos(iname))
            initVal = M.Assign(1,assignPos(iname),:) ;
        else
            initVal = M.stdcorr(1,stdcorrPos(iname),:) ;
        end
    else
        % use initial condition from prior struct
        initVal = param{1} ;
    end
    
    % get prior
    if numel(param) > 3 && ~isempty(param{4})
        fh = param{4} ;
        % check prior consistency
        if isinf(fh(initVal))
            validPrior(iname) = false ;
        end
    end
    
    % check bounds consistency
    if ~isempty(param{2})
        if ( param{2}>-realmax )
            % lower bound is non-empty and not -Inf
            if ( initVal<param{2} )
                validBound(iname) = false ;
            end
        end
    end
    if ~isempty(param{3})
        if ( param{3}<realmax )
            % upper bound is non-empty and not Inf
            if ( initVal>param{3} )
                validBound(iname) = false ;
            end
        end
    end
end

Flag = all(validPrior) && all(validBound) && all(found) ;
PriorList = pnames(~validPrior) ;
BoundList = pnames(~validBound) ;
NotFoundList = pnames(~found) ;

end




