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
% of column vectors is supported, although IRIS will figure out the input
% is an array of row vectors provided the dimensions do not make this
% ambiguous. 
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
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin<3
    % Normal distribution by default
    Df = Inf ;
end

mode = Mean(:) ;
a = Mean(:) ;

if numel(Mean) > 1
    % Distribution is multivariate
    if norm(triu(Std)-Std) < eps
        % Matrix is already square root
        b = Std ;
    else
        % Compute square root matrix using Cholesky
        b = chol(Std) ;
    end
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

% Subfunctions.

%**************************************************************************
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
    Y = xxLogMultNormal() ;
    return
end

switch lower(varargin{1})
    case {'proper','pdf'}
        Y = exp(xxLogMultNormal()) ;
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
        Y = 'multnormal';
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

    function Y = xxLogMultNormal()
        tpY = false ;
        if size(X,1)~=numel(Mu)
            X = X' ;
            tpY = true ;
        end
        sX = bsxfun(@minus, X, Mu)' / Std ;
        logSqrtDetSig = sum(log(diag(Std))) ;
        Y = -0.5*K*log(2*pi) - logSqrtDetSig - 0.5*sum(sX.^2,2)' ;
        if tpY
            Y = Y' ;
        end
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
    case {'proper','pdf'}
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
        Y = 'multnormal';
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
        Y = bsxfun(@plus, Mu, R) ;
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
        Y = 'multnormal';
    case 'draw'
        if numel(varargin)<2
            dim = size(Mu) ;
        else
            dim = varargin{2:end} ;
        end
        C = sqrt( Df ./ chi2fh([], 'draw', dim) ) ;
        R = bsxfun(@times, Std*randn(dim), C) ;
        Y = bsxfun(@plus, Mu, R) ;
end

    function Y = xxLogT()
        sX = bsxfun(@minus, X, Mu)' / Std ;
        Y = ( gammaln(0.5*(Df+1)) - gammaln(0.5*Df) - log(sqrt(Df*pi)*Std) ) ...
            - 0.5*(Df+1)*log1p( sX.^2/Df ) ;
    end

end % xxT()