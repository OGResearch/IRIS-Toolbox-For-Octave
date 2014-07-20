function [Ans,Flag] = specget(This,Query)
% specget  [Not a public function] Implement GET method for VAR objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

[Ans,Flag] = specget@varobj(This,Query);
if Flag
    return
end

Ans = [];
Flag = true;

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

Query = lower(Query);
switch Query
    
    case {'a','a#'}
    % Transition matrix.
        if isequal(Query,'a')
            % ##### Feb 2014 OBSOLETE and scheduled for removal.
            utils.warning('VAR:specget', ...
                ['The query ''A'' into VAR objects is no longer valid, ', ...
                'and will be removed from a future version of IRIS. ', ...
                'Use ''A#'' instead.']);
        end
        if ~all(size(This.A) == 0)
            Ans = poly.var2poly(This.A);
        end
        
    case 'a*'
        if ~all(size(This.A) == 0)
            Ans = poly.var2poly(This.A);
            Ans = -Ans(:,:,2:end,:);
        end
        
    case 'a$'
        Ans = This.A;
        
    case {'const','c','k'}
        % Constant vector or matrix (for panel VARs).
        Ans = This.K;
        
    case 'j'
        % Coefficient matrix in front exogenous inputs.
        Ans = This.J;
        
    case 'g'
        % Estimated coefficients on user-specified cointegration terms.
        Ans = This.G;
        
    case 't'
        % Schur decomposition.
        Ans = This.T;
        
    case 'u'
        Ans = This.U;
        
    case {'omega','omg'}
        % Cov matrix of forecast errors (reduced form residuals); remains the
        % same in SVAR objects.
        Ans = This.Omega;
        
    case {'cov'}
        % Cov matrix of reduced form residuals in VARs or structural shocks in
        % SVARs.
        Ans = This.Omega;
        
    case {'sgm','sigma','covp','covparameters'}
        % Cov matrix of parameter estimates.
        Ans = This.Sigma;
        
    case {'xasymptote','x0'}
        Ans = This.X0;
        
    case 'aic'
        % Akaike info criterion.
        Ans = This.Aic;
        
    case 'sbc'
        % Schwarz bayesian criterion.
        Ans = This.Sbc;
        
    case {'nfree','nhyper'}
        % Number of freely estimated (hyper-) parameters.
        Ans = This.NHyper;
        
    case {'order','p'}
        % Order of VAR.
        Ans = p;
        
    case {'cumlong','cumlongrun'}
        % Matrix of long-run cumulative responses.
        C = sum(poly.var2poly(This.A),3);
        Ans = nan(ny,ny,nAlt);
        for iAlt = 1 : nAlt
            if rank(C(:,:,1,iAlt)) == ny
                Ans(:,:,iAlt) = inv(C(:,:,1,iAlt));
            else
                Ans(:,:,iAlt) = pinv(C(:,:,1,iAlt));
            end
        end
        
    case {'constraints','restrictions','constraint','restrict'}
        % Parameter constraints imposed in estimation.
        Ans = This.Rr;
        
    case {'inames','ilist'}
        Ans = This.INames;
        
    case {'ieqtn'}
        Ans = This.IEqtn;
        
    case {'zi'}
        % The constant term comes first in Zi, but comes last in user
        % inputs/outputs.
        Ans = [This.Zi(:,2:end),This.Zi(:,1)];
        
    case 'ny'
        Ans = size(This.A,1);
        
    case 'ne'
        Ans = size(This.Omega,2);
        
    case 'ni'
        Ans = size(This.Zi,1);
        
    otherwise
        Flag = false;
        
end

end
