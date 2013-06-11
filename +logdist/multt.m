function F = multt(Mean,Std,Df)
% multt  Create function proportional to log of the multivariate T distribution.
%
% Syntax
% =======
%
%     F = logdist.multt(Mean,Std,Df)
%
% Input arguments
% ================
%
% * `Mean` [ numeric ] - Mean of the multivariate T distribution.
%
% * `Std` [ numeric ] - Std dev of the multivariate T distribution.
%
% * `Df` [ integer ] - Degrees of freedom of multivariate T distribution.
%
% Output arguments
% =================
%
% * `F` [ function_handle ] - Function handle returning a value
% proportional to the log of the multivariate T density.
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

if isinf(gammaln(Df))
    F = logdist.multnormal(Mean,Std) ;
else
    F = @(x,varargin) xxMultT(x,a,b,Mean,Std,Df,mode,varargin{:});
end
end

% Subfunctions.

%**************************************************************************
function Y = xxMultT(X,A,B,Mu,Std,Df,Mode,varargin)

K = numel(Mu) ;
if isempty(varargin)
    Y = xxLogMultT() ;
    return
end

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
        Y = bsxfun(@plus,Mu,Std*randn(dim)) ;
end

    function Y = xxLogMultT()
        X = reshape(X,size(Mu)) ;
        sX = bsxfun(@minus, X, Mu)' / Std ;
        logSqrtDetSig = sum(log(diag(Std))) ;
        Y = ( gammaln(0.5*(Df+K)) - gammaln(0.5*Df) ...
            - logSqrtDetSig - 0.5*K*log(Df*pi) ) ...
            - 0.5*(Df+K)*log1p( ...
            sum(sX.^2,2)/Df...
            ) ;
    end

end