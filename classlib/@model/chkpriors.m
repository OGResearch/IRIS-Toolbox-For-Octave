function [Pvec] = chkpriors(M,E)
% chkpriors  Check consistency of priors and bounds with initial
% conditions.
%
% Syntax
% =======
%
%     [Pvec] = chkpriors(M,E)
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
% * `Pvec` [ logical ] - Logical array indicating true when prior
% distributions and bounds are consistent with initial values.
%
% Options
% ========
%

% Validate input arguments
pp = inputParser();
pp.addRequired('M',@ismodel);
pp.addRequired('E',@(x) isstruct(x));
pp.parse(M,E);

% Check consistency by looping over parameters
pnames = fields(E) ;
np = numel(pnames) ;
Pvec = true(np,1) ;
for iname = 1:np
    param = E.(pnames{iname}) ;
    if isnan(param{1})
        % use initial condition from model object
        initVal = M.(pnames{iname}) ;
    else
        % use initial condition from prior struct
        initVal = param{1} ;
    end
    
    % get prior
    if numel(param)<4
        fh = @(x) 1 ;
    else
        fh = param{4} ;
    end
    
    % check prior consistency
    if isinf(fh(initVal))
        utils.warning('model:chkpriors',...
            'Initial value of %g for parameter %s is inconsistent with the prior distribution support.',initVal,pnames{iname}) ;
        Pvec(iname) = false ;
    end
    
    % check bounds consistency
    if ~isempty(param{2})
        if ( param{2}>-realmax )
            % lower bound is non-empty and not -Inf
            if ( initVal<param{2} )
                Pvec(iname) = false ;
                utils.warning('model:chkpriors',...
                    'Initial value of %g for parameter %s is lower than the lower bound %g.',initVal,pnames{iname},param{2}) ;
            end
        end
    end
    if ~isempty(param{3})
        if ( param{3}<realmax )
            % upper bound is non-empty and not Inf
            if ( initVal>param{3} )
                Pvec(iname) = false ;
                utils.warning('model:chkpriors',...
                    'Initial value of %g for parameter %s is higher than the upper bound %g.',initVal,pnames{iname},param{2}) ;
            end
        end
    end
end

end




