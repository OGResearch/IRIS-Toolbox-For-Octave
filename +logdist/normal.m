function F = normal(Mean,Std,Df)
% normal  Create function proportional to log of Normal or Student distribution.
%
% Syntax
% =======
%
%     F = logdist.normal(Mean,Std,Df)
%
% Input arguments
% ================
%
% * `Mean` [ numeric ] - Mean of the normal distribution.
%
% * `Std` [ numeric ] - Std dev of the normal distribution.
%
% * `Df` [ integer ] - Number of degrees of freedom. If finite, the
% distribution is Student T; if omitted or `Inf` (default) the distribution
% is Normal.
%
% Multivariate cases are supported. Evaluating multiple vectors as an array
% of column vectors is supported.
%
% If the mean and standard deviation are cell arrays then the distribution
% will be a mixture of normals. In this case the third argument is the
% vector of mixture weights.
%
% Output arguments
% =================
%
% * `F` [ function_handle ] - Function handle returning a value
% proportional to the log of Normal or Student density.
%
% Description
% ============
%
% See [help on the logdisk package](logdist/Contents) for details on using
% the function handle `F`.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team and Boyan Bejanov.

%--------------------------------------------------------------------------

if nargin<3
    % Normal distribution by default
    Df = Inf ;
end

if iscell( Mean )
    % Distribution is a mixture
    Weight = Df / sum(Df) ;    
    K = numel( Mean{1} ) ;
    Nmix = numel( Mean ) ;
    if K > 1
        for d = 1:Nmix
            assert( all( size(Std{d}) == numel(Mean{d}) ), ...
                'Mean and covariance matrix dimensions must be consistent.' ) ;
            assert( all( size(Mean{d}) == size(Mean{1}) ), ...
                'Mixture dimensions must be consistent.' ) ;
            Std{d} = xxChkStd( Std{d} ) ;
        end
    end
    a = zeros(K,1) ;
    for d = 1:Nmix
        a = a + Weight(d)*Mean{d} ;
    end
    F = @(x,varargin) xxMultNormalMixture(x,a,Mean,Std,Weight,varargin{:}) ;
else
    % Distribution is either univariate t/normal or multivariate t/normal
    mode = Mean(:) ;
    a = Mean(:) ;
    
    if numel(Mean) > 1
        % Distribution is multivariate
        Std = xxChkStd( Std ) ;
        
        if isinf(gammaln(Df))
            F = @(x,varargin) xxMultNormal(x,a,b,Mean,Std,mode,varargin{:}) ;
        else
            F = @(x,varargin) xxMultT(x,a,b,Mean,Std,Df,mode,varargin{:}) ;
        end
    else
        % Distribution is scalar
        b = Std ;
        if isinf(gammaln(Df))
            F = @(x,varargin) xxNormal(x,a,b,Mean,Std,mode,varargin{:}) ;
        else
            F = @(x,varargin) xxT(x,a,b,Mean,Std,Df,mode,varargin{:}) ;
        end
    end
end

    function C = xxChkStd(C)
        if norm(triu(C)-C) < eps
            % Matrix is already square root
            b = C ;
        else
            % Compute square root matrix using Cholesky
            b = chol(C) ;
        end
    end

end

% Subfunctions.

%**************************************************************************
function Y = xxMultNormalMixture(X,A,Mu,Std,Weight,varargin)
Nmix = numel(Mu) ;
K = numel(Mu{1}) ;

if isempty(varargin)
    Y = log(xxMixturePdf()) ;
    return
end

switch lower(varargin{1})
    case {'proper','pdf'}
        Y = xxMixturePdf() ;
    case 'draw'
        if numel(varargin)<2
            NDraw = 1 ;
        else
            NDraw = varargin{2} ;
        end
        Y = NaN(K,NDraw) ;
        bin = multinomialRand( NDraw, Weight ) ;
        for c = 1:Nmix
            ind = ( bin == c ) ;
            NC = sum( ind ) ;
            if NC>0
                Y(:,ind) = bsxfun( @plus, Mu{c}, Std{c}*randn(K,NC) ) ;
            end
        end
    case 'name'
        Y = 'normal' ;
    case 'mean'
        Y = Mu ;
    case {'sigma','sgm','std'}
        Y = Std ;
    case {'a','location'}
        Y = A;
    case {'b','scale'}
        Y = B;
end

    function bin = multinomialRand(NDraw, Prob)
        CS = cumsum(Prob(:).');
        bin = 1+sum( bsxfun(@gt, rand(NDraw,1), CS), 2);
    end

    function Y = xxMixturePdf()
        [N1,N2] = size(X) ;
        Y = zeros(1,N2) ;
        assert( N1 == K, 'Input must be a column vector.' ) ;
        for m = 1:Nmix
            Y = bsxfun(@plus, Y, ...
                Weight(m)*exp(xxLogMultNormalPdf(X,Mu{m},Std{m}))...
                ) ;
        end
    end
end

function Y = xxLogMultNormalPdf(X,Mu,Std)
K = numel(Mu) ;
sX = bsxfun(@minus, X, Mu)' / Std ;
logSqrtDetSig = sum(log(diag(Std))) ;
Y = -0.5*K*log(2*pi) - logSqrtDetSig - 0.5*sum(sX.^2,2)' ;
end

function Y = xxNormal(X,A,B,Mu,Std,Mode,varargin)

if isempty(varargin)
    Y = -0.5 * ((X - Mu)./Std).^2;
    return
end

switch lower(varargin{1})
    case {'proper','pdf'}
        Y = 1/(Std*sqrt(2*pi)) .* exp(-(X-Mu).^2/(2*Std^2));
    case 'info'
        Y = 1/(Std^2)*ones(size(X));
    case {'a','location'}
        Y = A;
    case {'b','scale'}
        Y = B;
    case 'mean'
        Y = Mu;
    case {'sigma','sgm','std'}
        Y = Std;
    case 'mode'
        Y = Mode;
    case 'name'
        Y = 'normal';
    case 'draw'
        Y = Mu + Std*randn(varargin{2:end});
end

end % xxNormal().

%**************************************************************************
function Y = xxMultNormal(X,A,B,Mu,Std,Mode,varargin)

K = numel(Mu) ;
if isempty(varargin)
    Y = xxLogMultNormalPdf(X,Mu,Std) ;
    return
end

switch lower(varargin{1})
    case {'proper','pdf'}
        Y = exp(xxLogMultNormalPdf(X,Mu,Std)) ;
    case 'info'
        Y = eye(size(Std)) / ( Std'*Std ) ;
    case {'a','location'}
        Y = A ;
    case {'b','scale'}
        Y = B ;
    case 'mean'
        Y = Mu ;
    case {'sigma','sgm','std'}
        Y = Std ;
    case 'mode'
        Y = Mode ;
    case 'name'
        Y = 'normal';
    case 'draw'
        if numel(varargin)<2
            dim = size(Mu) ;
        else
            if numel(varargin{2})==1
                dim = [K,varargin{2}] ;
            else
                dim = varargin{2} ;
            end
        end
        Y = bsxfun(@plus,Mu,Std*randn(dim)) ;
end

end % xxMultNormal()

%**************************************************************************
function Y = xxMultT(X,A,B,Mu,Std,Df,Mode,varargin)

K = numel(Mu) ;
if isempty(varargin)
    Y = xxLogMultT() ;
    return
end
chi2fh = logdist.chisquare(Df) ;

switch lower(varargin{1})
    case 'draw'
        if numel(varargin)<2
            dim = size(Mu) ;
        else
            if numel(varargin{2})==1
                dim = [K,varargin{2}] ;
            else
                dim = varargin{2} ;
            end
        end
        C = sqrt( Df ./ chi2fh([], 'draw', dim) ) ;
        R = bsxfun(@times, Std*randn(dim), C) ;
        Y = bsxfun(@plus, Mu, R) ;    case {'proper','pdf'}
        Y = exp(xxLogMultT()) ;
    case 'info'
        % add this later...
        Y = NaN(size(Std)) ;
    case {'a','location'}
        Y = A ;
    case {'b','scale'}
        Y = B ;
    case 'mean'
        Y = Mu ;
    case {'sigma','sgm','std'}
        Y = Std ;
    case 'mode'
        Y = Mode ;
    case 'name'
        Y = 'normal';
end

    function Y = xxLogMultT()
        tpY = false ;
        if size(X,1)~=numel(Mu)
            X=X';
            tpY = true ;
        end
        sX = bsxfun(@minus, X, Mu)' / Std ;
        logSqrtDetSig = sum(log(diag(Std))) ;
        Y = ( gammaln(0.5*(Df+K)) - gammaln(0.5*Df) ...
            - logSqrtDetSig - 0.5*K*log(Df*pi) ) ...
            - 0.5*(Df+K)*log1p( ...
            sum(sX.^2,2)'/Df...
            ) ;
        if tpY
            Y = Y' ;
        end
    end

end % xxMultT()

%**************************************************************************
function Y = xxT(X,A,B,Mu,Std,Df,Mode,varargin)

if isempty(varargin)
    Y = xxLogT() ;
    return
end
chi2fh = logdist.chisquare(Df) ;

switch lower(varargin{1})
    case 'draw'
        if numel(varargin)<2
            dim = size(Mu) ;
        else
            dim = varargin{2:end} ;
        end
        C = sqrt( Df ./ chi2fh([], 'draw', dim) ) ;
        R = bsxfun(@times, Std*randn(dim), C) ;
        Y = bsxfun(@plus, Mu, R) ;
    case {'icdf','quantile'}
        Y = NaN(size(X)) ;
        Y( X<eps ) = -Inf ;
        Y( 1-X<eps ) = Inf ;
        ind = ( X>=eps ) & ( (1-X)>=eps ) ;
        pos = ind & ( X>0.5 ) ;
        X( ind ) = min( X(ind), 1-X(ind) ) ;
        % this part for accuracy
        low = ind & ( X<=0.25 ) ;
        high = ind & ( X>0.25 ) ;
        qs = betaincinv( 2*X(low), 0.5*Df, 0.5 ) ;
        Y( low ) = -sqrt( Df*(1./qs-1) ) ;
        qs = betaincinv( 2*X(high), 0.5, 0.5*Df, 'upper' ) ;
        Y( high ) = -sqrt( Df./(1./qs-1) ) ;
        Y( pos ) = -Y( pos ) ;
        Y = Mu + Y*Std ;
    case {'proper','pdf'}
        Y = exp(xxLogT()) ;
    case 'info'
        % add this later...
        Y = NaN(size(Std)) ;
    case {'a','location'}
        Y = A ;
    case {'b','scale'}
        Y = B ;
    case 'mean'
        Y = Mu ;
    case {'sigma','sgm','std'}
        Y = Std ;
    case 'mode'
        Y = Mode ;
    case 'name'
        Y = 'normal';
end

    function Y = xxLogT()
        sX = bsxfun(@minus, X, Mu)' / Std ;
        Y = ( gammaln(0.5*(Df+1)) - gammaln(0.5*Df) - log(sqrt(Df*pi)*Std) ) ...
            - 0.5*(Df+1)*log1p( sX.^2/Df ) ;
    end

end % xxT()