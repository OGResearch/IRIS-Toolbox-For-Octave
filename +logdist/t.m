function F = t(Mean,Std,Df)
% t  Create function proportional to log of Student T distribution.
%
% Syntax
% =======
%
%     F = logdist.t(Mean,Std,Df)
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
% -Copyright (c) 2007-2014 IRIS Solutions Team and Boyan Bejanov.

if nargin<3
    Df = Inf ;
end

mode = Mean(:) ;
a = Mean(:) ;

if numel(Mean) > 1
    % Distribution is multivariate
    Std = logdist.mychkstd( Std ) ;
    b = Std ;
    
    if isinf(gammaln(Df))
        F = logdist.normal(Mean,Std) ;
    else
        F = @(x,varargin) xxMultT(x,a,b,Mean,Std,Df,mode,varargin{:}) ;
    end
else
    % Distribution is scalar
    b = Std ;
    if isinf(gammaln(Df))
        F = logdist.normal(Mean,Std) ;
    else
        F = @(x,varargin) xxT(x,a,b,Mean,Std,Df,mode,varargin{:}) ;
    end
end
end

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