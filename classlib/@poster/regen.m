function [Theta,LogPost,AccRatio,Sgm,FinalCov] ...
    = regen(This,NDraw,varargin)
% arwm  Regeneration time MCMC Metropolis posterior simulator.
%
% Syntax
% =======
%
%     [Theta,LogPost,AR,Scale,FinalCov] = regen(Pos,NDraw,...)
%
% Input arguments
% ================
%
% * `Pos` [ poster ] - Initialised posterior simulator object.
%
% * `NDraw` [ numeric ] - Length of the chain not including burn-in.
%
% Output arguments
% =================
%
% * `Theta` [ numeric ] - MCMC chain with individual parameters in rows.
%
% * `LogPost` [ numeric ] - Vector of log posterior density (up to a
% constant) in each draw.
%
% * `AR` [ numeric ] - Vector of cumulative acceptance ratios in each draw.
%
% * `Scale` [ numeric ] - Vector of proposal scale factors in each draw.
%
% * `FinalCov` [ numeric ] - Final proposal covariance matrix; the final
% covariance matrix of the random walk step is Scale(end)^2*FinalCov.
%
% Options
% ========
% 
% References
% ========
% 1. Brockwell, A.E., and Kadane, J.B., 2004. "Identification of ]
%    Regeneration Times in MCMC Simulation, with Application to Adaptive 
%    Schemes," mimeo, Carnegie Mellon University. 
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team & Bojan Bejanov & Troy Matheson.

% Validate required inputs.
pp = inputParser();
pp.addRequired('Pos',@(x) isa(x,'poster'));
pp.addRequired('NDraw',@isnumericscalar);
pp.parse(This,NDraw);

% Parse options.
opt = passvalopt('poster.regen',varargin{:});

%--------------------------------------------------------------------------

% Number of estimated parameters.
nPar = length(This.paramList);

% Generate initial chain and construct reentry distribution
[initTheta,initLogPost,initAccRatio,initSgm,initFinalCov] ...
    = arwm(This,opt.InitialChainSize,'lastAdapt=',1) ; %#ok<*ASGLU,*NASGU>

initStd = chol(cov(initTheta')) ;
initMean = mean(initTheta,2) ;
reentryDist = logdist.normal(initMean,initStd) ;
reentrySample = reentryDist([],'draw',opt.InitialChainSize) ;

% Construct proposal distribution
propNew = @(x) rwrand(x,chol(FinalCov)) ;

K = mean(exp(initLogPost)) / mean(exp(reentryDist(reentrySample))) ;
lnK = log(K) ;

% the Alpha state is something out of this world (or at least out of the
% support of Theta...)
alphaState = NaN(nPar,1) ; 
isAlphaState = @(x) all(isnan(x),1) ; % tests which column vectors are NaN

%--------------------------------------------------------------------------
% Main loop
Yt = alphaState ; %start in Alpha state
lp_Yt = NaN ;
t = 0 ;
s = 1 ;
while t < n
    t = t + 1 ;
    lp_V = NaN ;
    lp_Z = NaN ;
    lp_W = NaN ;
    alpha_W = NaN ;
    accZ = 0 ;
    accV = 0 ;
    accW = 0 ;
    
    if isAlphaState(Yt)
        V = alphaState ;
    else
        Z = propNew(  ) ;
        
    end
end

    function thetaNew = rwrand(theta, sig)
        u = randn(nPar,1) ;
        newTheta = theta + sig*u ;
    end

end