function P = chkpriors(M,E)
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
% * `P` [ cellstr ] - Cell array of strings of parameters which are
% inconsistent with priors and/or bounds.
%
% Options
% ========
%

% Validate input arguments
pp = inputParser() ;
pp.addRequired('M',@ismodel) ;
pp.addRequired('E',@(x) isstruct(x)) ;
pp.parse(M,E) ;

P = {} ;

% Get list of parameters and shocks
eList = M.name(M.nametype == 3) ;
pList = M.name(M.nametype == 4) ;

% Check consistency by looping over parameters
pnames = fields(E) ;
np = numel(pnames) ;
for iname = 1:np
    param = E.(pnames{iname}) ;
    if isnan(param{1})
        % use initial condition from model object
        if strncmp('std_',pnames{iname},4)
            % shock
            initVal = M.stdcorr( strcmp(eList,pnames{iname}(5:end)) ) ;
        else
            % parameter
            initVal = M.Assign( strcmp(pList,pnames{iname}) ) ;
        end
    else
        % use initial condition from prior struct
        initVal = param{1} ;
    end
    
    % get prior
    if numel(param)<4
        fh = @(x) 1 ;
    else
        if isempty(param{4})
            fh = @(x) 1 ;
        else
            fh = param{4} ;
        end
    end
    
    % check prior consistency
    if isinf(fh(initVal))
        P = [P,pnames(iname)] ;
    end
    
    % check bounds consistency
    if ~isempty(param{2})
        if ( param{2}>-realmax )
            % lower bound is non-empty and not -Inf
            if ( initVal<param{2} )
                P = [P,pnames(iname)] ;
            end
        end
    end
    if ~isempty(param{3})
        if ( param{3}<realmax )
            % upper bound is non-empty and not Inf
            if ( initVal>param{3} )
                P = [P,pnames(iname)] ;
            end
        end
    end
end

end




