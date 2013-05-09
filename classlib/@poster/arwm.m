function [Theta,LogPost,AccRatio,Sgm,FinalCov,SaveCount] ...
    = arwm(This,NDraw,varargin)
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

s = mylogpoststruct(This);

Theta = [];
LogPost = [];
AccRatio = [];
Sgm = [];
FinalCov = []; %#ok<NASGU>

% Number of estimated parameters.
nPar = length(This.paramList);

% Adaptive random walk Metropolis simulator.
nAlloc = min(NDraw,opt.saveevery);
isSave = opt.saveevery <= NDraw;
if isSave
    doChkSaveOptions();
end

sgm = opt.initscale;
if opt.burnin < 1
    % Burn-in is a percentage.
    burnin = round(opt.burnin*NDraw);
else
    % Burn-in is a number of draws.
    burnin = opt.burnin;
end

nDrawTotal = NDraw + burnin;
gamma = opt.gamma;
k1 = opt.adaptscale;
k2 = opt.adaptproposalcov;
targetAR = opt.targetar;

isAdaptiveScale = isfinite(gamma) && k1 > 0;
isAdaptiveShape = isfinite(gamma) && k2 > 0;
isAdaptive = isAdaptiveScale || isAdaptiveShape;

theta = This.initParam(:);
P = chol(This.initProposalCov).';
logPost = mylogpost(This,theta,s);

% Pre-allocate output data.
Theta = zeros(nPar,nAlloc);
LogPost = zeros(1,nAlloc);
AccRatio = zeros(1,nAlloc);
if isAdaptiveScale
    Sgm = zeros(1,nAlloc);
else
    Sgm = sgm;
end

if opt.progress
    progress = progressbar('IRIS poster.arwm progress');
elseif opt.esttime
    eta = esttime('IRIS poster.arwm is running');
end

% Main loop
%-----------

nAccepted = 0;
count = 0;
SaveCount = 0;
for j = 1 : nDrawTotal
    % Propose a new theta.
    u = randn(nPar,1);
    newTheta = theta + sgm*P*u;
    
    % Evaluate log posterior.
    newLogPost = mylogpost(This,newTheta,s);
    
    % Prob of new proposal being accepted.
    alpha = min(1,exp(newLogPost-logPost));
    % Decide if we accept the new theta.
    accepted = rand() <= alpha;
    if accepted
        logPost = newLogPost;
        theta = newTheta;
    end
    % Adapt the scale and/or proposal covariance.
    if isAdaptive
        doAdapt();
    end
    % Add the j-th theta to the chain unless it's burn-in sample.
    if j > burnin
        count = count + 1;
        nAccepted = nAccepted + double(accepted);
        % Paremeter draws.
        Theta(:,count) = theta;
        % Value of log posterior at the current draw.
        LogPost(count) = logPost;
        % Acceptance ratio so far.
        AccRatio(count) = nAccepted / (j-burnin);
        % Adaptive scale factor.
        if isAdaptiveScale
            Sgm(count) = sgm;
        end
        if count == opt.saveevery ...
                || (isSave && j == nDrawTotal)
            count = 0;
            doSave();
        end
    end
    % Update the progress bar or estimated time.
    if opt.progress
        update(progress,j/nDrawTotal);
    elseif opt.esttime
        update(eta,j/nDrawTotal);
    end
end

FinalCov = P*P.';

if isSave
    % Save master file with the following information
    % * `PList` -- list of estimated parameters;
    % * `SaveCount` -- the total number of files;
    % * `NDraw` -- the total number of non-discarded draws;
    PList = This.paramList; %#ok<NASGU>
    save(opt.saveas,'PList','SaveCount','NDraw');
end

% Nested functions.

%**************************************************************************
    function doChkSaveOptions()
        if isempty(opt.saveas)
            utils.error('poster', ...
                'The option ''saveas='' must be a valid file name.');
        end
        [p,t] = fileparts(opt.saveas);
        opt.saveas = fullfile(p,t);
    end % doChkSaveOptions().

%**************************************************************************
    function doSave()
        SaveCount = SaveCount + 1;
        filename = [opt.saveas,sprintf('%g',SaveCount)];
        save(filename,'Theta','LogPost','-v7.3');
        togo = nDrawTotal-j;
        if togo == 0
            Theta = [];
            LogPost = [];
            AccRatio = [];
            Sgm = [];
        elseif togo < nAlloc
            Theta = Theta(:,1:togo);
            LogPost = LogPost(1:togo);
            AccRatio = AccRatio(1:togo);
            if isAdaptiveScale
                Sgm = Sgm(1:togo);
            end
        end
    end % doSave().

%**************************************************************************
    function doAdapt()
        nu = j^(-gamma);
        phi = nu*(alpha - targetAR);
        if isAdaptiveScale
            phi1 = k1*phi;
            sgm = exp(log(sgm) + phi1);
        end
        if isAdaptiveShape
            phi2 = k2*phi;
            unorm2 = u.'*u;
            z = sqrt(phi2/unorm2)*u;
            P = cholupdate(P.',P*z).';
        end
    end % doAdapt();

end