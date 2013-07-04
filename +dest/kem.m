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
% References
% ===========
%
% 1. Hamerly and Elkhan (2002) "Alternatives to the k-means algorithm that
%    find better clusterings."

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team and Boyan Bejanov.

pp = inputParser();
pp.addRequired('Sample', @isnumeric );
pp.parse( Sample );

% Parse options.
opt = passvalopt('dest.kcluster',varargin{:});

% Constants
[D,N] = size(Sample) ;
if D>N
    Sample = Sample' ;
    [N,D] = deal(D,N) ;
end

if strcmpi(opt.selectk,'fixed')
    [M, Sig, W] = xxKcluster( Sample, opt.k );
else
    logN = log(length(Sample)) ;
    bic = Inf ;
    tol = sqrt(eps) ;
    for k=1:opt.k
        % try k-means cluster
        [kM, kSig, kW, kLik] = xxKcluster( Sample, k );
        
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
        
        % compute BIC
        kBic = -2*kLik + k*logN;
        
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

    function [M, Sig, W, lLik, ik] = xxKcluster(Sample, K)
        
        thisSample = Sample ;
        
        % pick k points from the bunch at random (Forgy)
        M = thisSample(:,randperm(N,K));
        
        % refine to find means
        [M, W, p] = refineCenters(K, M);
        
        % Estimate covariance matrices via EM
        Sig = cell(1,K);
        lLik = 0 ;
        for ik = 1:K
            thisCov = zeros(D,D) ;
            mkSample = bsxfun(@minus, thisSample, M{ik}) ;
            kSumP = sum(p(ik,:)) ;
            for iobs = 1:N
                thisCov = thisCov + p(ik,iobs)*( mkSample(:,iobs)*mkSample(:,iobs)' ) / kSumP ;
            end
            Sig{ik} = chol( thisCov ) ;
            lLik = lLik + W(ik)*exp( -0.5*sum( ( mkSample / Sig{ik} ).^2, 1 ) / ( sqrt(2*pi).^D * prod(diag(Sig{ik})) ) ) ;
        end
        
        function [M,W,p,ik,iobs] = refineCenters(thisK, M)
            % Iterative refinement of k harmonic means using the algorithm
            % described in Zhang, Hsu and Dayal (1999).
            p = NaN(thisK,N) ;
            it = 0 ;
            crit = Inf ;
            M0 = M ;
            while it<opt.maxit && crit>opt.tol
                for iobs = 1:N
                    qVec = qCalc( thisSample(:,iobs), M, thisK ) ;
                    p(:,iobs) = qVec ./ sum(qVec) ;
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
            
            function [q,ik] = qCalc( X, M, thisK )
                d = NaN(K,1) ;
                for ik=1:thisK
                    d(ik) = max( norm( X-M(:,ik) ), 1e-14 ) ;
                end
                [dMin,minInd] = min(d) ;
                r = ( dMin ./ d ).^2 ;
                lInd = true(thisK,1) ;
                lInd(minInd) = false ;
                q = r.^3*dMin / (1 + sum(r(lInd)))^2 ;
            end
            
        end %refineCenters
    end %xxKcluster

end % kcluster().





