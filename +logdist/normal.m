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
% * `W` [ numeric ] - Optional input containing mixture weights.
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
% proportional to the log of Normal density.
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
            Std{d} = mychkstd( Std{d} ) ;
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
        Std = logdist.mychkstd( Std ) ;
        b = Std ;
        
        F = @(x,varargin) xxMultNormal(x,a,b,Mean,Std,mode,varargin{:}) ;
    else
        % Distribution is scalar
        b = Std ;
        F = @(x,varargin) xxNormal(x,a,b,Mean,Std,mode,varargin{:}) ;
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

