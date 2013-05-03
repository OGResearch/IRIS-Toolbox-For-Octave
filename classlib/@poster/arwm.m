function varargout = arwm(This,NDraw,varargin)
% arwm  Adaptive random-walk Metropolis posterior simulator.
%
% Syntax
% =======
%
%     [Theta,LogPost,AR,Scale,FinalCov] = arwm(Pos,NDraw,...)
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
% * `'adaptProposalCov='` [ numeric | *`0.5`* ] - Speed of adaptation of
% the Cholesky factor of the proposal covariance matrix towards the target
% acceptanace ratio, `targetAR`; zero means no adaptation.
%
% * `'adaptScale='` [ numeric | *`1`* ] - Speed of adaptation of the scale
% factor to deviations of acceptance ratios from the target ratio,
% `targetAR`.
%
% * `'burnin='` [ numeric | *`0.10`* ] - Number of burn-in draws entered
% either as a percentage of total draws (between 0 and 1) or directly as a
% number (integer greater that one). Burn-in draws will be added to the
% requested number of draws `ndraw` and discarded after the posterior
% simulation.
%
% * `'estTime='` [ `true` | *`false`* ] - Display and update the estimated time
% to go in the command window.
%
% * `'gamma='` [ numeric | *`0.8`* ] - The rate of decay at which the scale
% and/or the proposal covariance will be adapted with each new draw.
%
% * `'initScale='` [ numeric | `1/3` ] - Initial scale factor by which the
% initial proposal covariance will be multiplied; the initial value will be
% adapted to achieve the target acceptance ratio.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the command
% window.
%
% *`'targetAR='` [ numeric | *`0.234`* ] - Target acceptance ratio.
%
% Description
% ============
%
% Use the [`poster/stats`](poster/stats) function to process the raw chain
% produced by `arwm`.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team & Troy Matheson.

% Validate required inputs.
pp = inputParser();
pp.addRequired('Pos',@(x) isa(x,'poster'));
pp.addRequired('NDraw',@isnumericscalar);
pp.parse(This,NDraw);

% Parse options.
opt = passvalopt('poster.arwm',varargin{:});

%--------------------------------------------------------------------------

[varargout{1:nargout}] = mysimulate(This,'arwm',NDraw,opt);

end