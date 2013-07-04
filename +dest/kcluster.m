function [M, Sig, W] = kcluster(Sample, varargin)
% kcluster  Multivariate distribution estimation using k-means
%
% Syntax
% =======
%
%     F = dest.kcluster(Data, K)
%
% Output arguments
% =================
%
% * `Data` [ numeric ]
%
% * `K` [ integer ]
%
% Input arguments
% ================
%
% * `Mu` [ numeric ] - Cell array of mixture means.
%
% * `Sig` [ numeric ] - Cell array of mixture covariance matrices.
%
% Description
% ============
% Uses k-harmonic means clustering to estimate a multivariate distribution 
% as a mixture of normals.
%
% References
% ===========
%
% 1. Zhang, Hsu and Dayal (1999) "K-Harmonic Means - A Data Clustering
%    Algorithm."
%
% 2. Hamerly and Elkhan (2002) "Alternatives to the k-means algorithm that
%    find better clusterings."

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('Sample', @isnumeric );
pp.parse( Sample );

% Parse options.
opt = passvalopt('dest.kem',varargin{:});

% Constants
[D,N] = size(Sample) ;
if D>N
    Sample = Sample' ;
    [N,D] = deal(D,N) ;
end

% display
if opt.display
    fprintf(1,'Clusters     BIC      log(L)      Penalty \n') ;
end

if strcmpi(opt.selectk,'fixed')
    [M, Sig, W, kLik, kBic] = xxKcluster( Sample, opt.k );
    fprintf(1,'%2.0g          %+4.2f      %+4.2f      %+4.2f \n',...
        k, kBic, kLik, pen) ;
else
    bic = Inf ;
    tol = sqrt(eps) ;
    for k=1:opt.k
        % try k-means cluster
        [kM, kSig, kW, kLik, kBic, pen] = xxKcluster( Sample, k );
        
        % check for repeated clusters
        repeated = false;
        for ik=1:k,
            if repeated, break; end
            for jj=ik+1:k
                repeated = sum( (kM{ik}-kM{jj}).^2 ) < tol ;
                if repeated, break; end;
            end;
        end;
        if repeated, continue; end
                
        % display
        if opt.display
            fprintf(1,'%2.0g          %+4.2f      %+4.2f      %+4.2f \n',...
                k, kBic, kLik, pen) ;
        end
        
        if kBic > bic,
            % increasing number of parameters fails to decrease likelihood
            return;
        end
        
        % output assignment
        M = kM;
        Sig = kSig;
        W = kW;
        bic = kBic;
    end %for
end %if

    function [M, Sig, W, lLik, BIC, penalty, ik] = xxKcluster(thisSample, thisK)
        
        % pick k points from the bunch at random (Forgy)
        M = thisSample(:,randperm(N,thisK));
        
        % refine to find means
        [M, W, p] = refineCenters(thisK, M);
        
        % Estimate covariance matrices via EM
        Sig = cell(1,thisK);
        Lik = 0 ;
        for ik = 1:thisK
            thisCov = zeros(D,D) ;
            mkSample = bsxfun(@minus, thisSample, M{ik}) ;
            kSumP = sum(p(ik,:)) ;
            for iobs = 1:N
                thisCov = thisCov + p(ik,iobs)*( mkSample(:,iobs)*mkSample(:,iobs)' ) / kSumP ;
            end
            Sig{ik} = chol( thisCov ) ;
            Lik = Lik + W(ik)*exp( -0.5*sum( ( Sig{ik}' \ mkSample ).^2, 1 ) / ( sqrt(2*pi).^D * prod(diag(Sig{ik})) ) ) ;
            lLik = log(sum(Lik,2)) ;
        end
        
        % compute BIC
        penalty = thisK*log(N) ;
        BIC = -2*lLik + penalty ;

        
        %************* nested functions ******************%
        
        function [M,W,p,ik,iobs] = refineCenters(thisK, M)
            % Iterative refinement of k harmonic means using the algorithm
            % described in Zhang, Hsu and Dayal (1999).
            p = NaN(thisK,N) ;
            pp = p ;
            it = 0 ;
            crit = Inf ;
            M0 = M ;
            while it<opt.maxit && crit>opt.tol
                if ~opt.vectorized
                    % keep this just because it is significantly easier to
                    % debug
                    for iobs = 1:N
                        [qVec] = qCalc( thisSample(:,iobs), M, thisK ) ;
                        p(:,iobs) = qVec ./ sum(qVec) ;
                    end
                else
                    p = pCalcVec( thisSample, M, thisK ) ;
                end
                for ik = 1:thisK
                    M(:,ik) = sum( bsxfun(@times, thisSample, p(ik,:) ), 2 ) / sum( p(ik,:) ) ;
                end
                crit = norm(M-M0) ;
                M0 = M ;
            end
            if it==opt.maxit
                utils.warning('dest:kcluster',['Iterative refinement of k-harmonic means' ...
                    'failed to converge to the tolerance %g within %g iterations.'],...
                    opt.tol,opt.maxit) ;
            end
            W = sum( p, 2 ) ;
            W = W ./ sum(W) ;
            M = num2cell( M, 1 ) ;
            
            function [q,r,d,ik] = qCalc( X, M, thisK )
                d = max( colDist( X, M' ), 1e-14 ) ;
                [dMin,minInd] = min(d) ;
                r = ( dMin ./ d ).^2 ;
                lInd = true(thisK,1) ;
                lInd(minInd) = false ;
                q = r.^3*dMin / (1 + sum(r(lInd)))^2 ;
            end
            
            function [p,ik] = pCalcVec( X, M, thisK )
                d = NaN(thisK,N) ;
                for ik = 1:thisK
                    dt = bsxfun(@minus, X, M(:,ik)) ;
                    dt = bsxfun(@power, dt, 2) ;
                    dt = sqrt(sum(dt,1)) ;
                    d(ik,:) = dt ;
                end
                d = bsxfun(@max, d, 1e-14) ;
                ds = sort(d) ;
                % r = ( dMin ./ d ).^2 ;
                r = bsxfun(@rdivide, ds(1,:), d) ;
                r = bsxfun(@power, r, 2) ;
                % q = r.^3*dMin / (1 + sum(r(lInd)))^2 ;
                r = bsxfun(@power, r, 3) ;
                r = bsxfun(@times, r, ds(1,:)) ;
                de = 1+sum(ds(2:end,:),1) ;
                de = bsxfun(@power, de, 2) ;
                q = bsxfun(@rdivide, r, de) ;
                % p = q ./ sum(q) ;
                qs = sum(q,1) ;
                p = bsxfun(@rdivide, q, qs) ;
            end
            
            function d = colDist( A, b )
                C = bsxfun(@minus, A, b) ;
                d = sqrt( sum( C.*C, 2 ) ) ;
            end
            
        end %refineCenters
    end %xxKcluster

end % kcluster().





