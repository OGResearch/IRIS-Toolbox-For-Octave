function F = multnormal(Mean,Std)
% normal  Create function proportional to log of multivariate 
% normal distribution.
%
% Syntax
% =======
%
%     F = logdist.multnormal(Mean,Std)
%
% Input arguments
% ================
%
% * `Mean` [ numeric ] - Mean of the multivariate normal distribution.
%
% * `Std` [ numeric ] - Either the covariance matrix (dense) or 
% Cholesky square root of the covariance matrix (upper triangular). 
%
% Output arguments
% =================
%
% * `F` [ function_handle ] - Function handle returning a value
% proportional to the log of the multivariate normal density.
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

a = Mean ;
mode = Mean ;
c = chol(Std) ;
if norm(Std-c) < eps
    b = Std ;
else
    b = c ;
end
F = @(x,varargin) xxMultNormal(x,a,b,Mean,Std,mode,varargin{:});

end

% Subfunctions.

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
        X = reshape(X,size(Mu)) ;
        sX = bsxfun(@minus, X, Mu)' / Std ;
        logSqrtDetSig = sum(log(diag(Std))) ;
        Y = -0.5*K*log(2*pi) - logSqrtDetSig - 0.5*sum(sX.^2) ;
    end

end