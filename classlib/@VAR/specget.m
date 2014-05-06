function [X,Flag] = specget(This,Query)
% specget  [Not a public function] Implement GET method for VAR objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

[X,Flag] = specget@varobj(This,Query);
if Flag
    return
end

X = [];
Flag = true;

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

Query = lower(Query);
switch Query
    
    % Transition matrix.
    case {'a','a#'}
        if isequal(Query,'a')
            % ##### Feb 2014 OBSOLETE and scheduled for removal.
            utils.warning('VAR:specget', ...
                ['The query ''A'' into VAR objects is no longer valid, ', ...
                'and will be removed from a future version of IRIS. ', ...
                'Use ''A#'' instead.']);
        end
        if ~all(size(This.A) == 0)
            X = poly.var2poly(This.A);
        end
        
    case 'a*'
        if ~all(size(This.A) == 0)
            X = poly.var2poly(This.A);
            X = -X(:,:,2:end,:);
        end
        
    case 'a$'
        X = This.A;
    
    % Constant vector or matrix (for panel VARs).
    case {'const','c','k'}
        X = This.K;
        
    % Estimated coefficients on user-specified cointegration terms.
    case 'g'
        X = This.G;
        
    % Schur decomposition.
    case 't'
        X = This.T;
        
    case 'u'
        X = This.U;
        
    % Cov matrix of forecast errors (reduced form residuals); remains the
    % same in SVAR objects.
    case {'omega','omg'}
        X = This.Omega;
    
    % Cov matrix of reduced form residuals in VARs or structural shocks in
    % SVARs.
    case {'cov'}
        X = This.Omega;
        
    % Cov matrix of parameter estimates.
    case {'sgm','sigma','covp','covparameters'}
        X = This.Sigma;
    
    % Akaike info criterion.
    case 'aic'
        X = This.Aic;
        
    % Schwarz bayesian criterion.
    case 'sbc'
        X = This.Sbc;
        
    % Number of freely estimated (hyper-) parameters.
    case {'nfree','nhyper'}
        X = This.NHyper;
      
    % Order of VAR.
    case {'order','p'}
        X = p;
        
    % Matrix of long-run cumulative responses.
    case {'cumlong','cumlongrun'}
        C = sum(poly.var2poly(This.A),3);
        X = nan(ny,ny,nAlt);
        for iAlt = 1 : nAlt
            if rank(C(:,:,1,iAlt)) == ny
                X(:,:,iAlt) = inv(C(:,:,1,iAlt));
            else
                X(:,:,iAlt) = pinv(C(:,:,1,iAlt));
            end
        end
        
    % Parameter constraints imposed in estimation.
    case {'constraints','restrictions','constraint','restrict'}
        X = This.Rr;

    case {'inames','ilist'}
        X = This.INames;
    case {'ieqtn'}
        X = This.IEqtn;
    case {'zi'}
        % The constant term comes first in Zi, but comes last in user
        % inputs/outputs.
        X = [This.Zi(:,2:end),This.Zi(:,1)];
    case 'ny'
        X = size(This.A,1);
    case 'ne'
        X = size(This.Omega,2);
    case 'ni'
        X = size(This.Zi,1);
    otherwise
        Flag = false;
end

end
