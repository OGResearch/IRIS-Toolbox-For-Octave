function [Theta,LogPost,AccRatio,Sgm,FinalCov] ...
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
% * `'estTime='` [ `true` | *`false`* ] - Display and update the estimated
% time to go in the command window.
%
% * `'firstPrefetch='` [ numeric | *`Inf`* ] - First draw where
% parallelised pre-fetching will be used; `Inf` means no pre-fetching.
%
% * `'gamma='` [ numeric | *`0.8`* ] - The rate of decay at which the scale
% and/or the proposal covariance will be adapted with each new draw.
%
% * `'initScale='` [ numeric | `1/3` ] - Initial scale factor by which the
% initial proposal covariance will be multiplied; the initial value will be
% adapted to achieve the target acceptance ratio.
%
% * `'lastAdapt='` [ numeric | *`Inf`* ] - Last point at which the proposal
% covariance will be adapted; `Inf` means adaptation will continue until
% the last draw. Can also be entered as a percentage of total draws
% (a number strictly between 0 and 1). 
%
% * `'nStep='` [ numeric | *`1` ] - Number of pre-fetched steps computed in
% parallel; only works with `firstPrefetch=` smaller than `NDraw`.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the
% command window.
%
% * `'saveAs='` [ char | *empty* ] - File name where results will be saved
% when the option `'saveEvery='` is used.
%
% * `'saveEvery='` [ numeric | *`Inf`* ] - Every N draws will be saved to
% an HDF5 file, and removed from workspace immediately; no values will be
% returned in the output arguments `Theta`, `LogPost`, `AR`, `Scale`; the
% option `'saveAs='` must be used to specify the file name; `Inf` means
% a normal run with no saving.
%
% * `'targetAR='` [ numeric | *`0.234`* ] - Target acceptance ratio.
%
% Description
% ============
%
% Use the [`poster/stats`](poster/stats) function to process the simulated
% chain of parameters, and calculate selected statistics.
%
% Parallelised ARWM
% ------------------
%
% Set `'nStep='` greater than `1`, and `'firstPrefetch='` smaller than
% `NDraw` to start a pre-fetching parallelised algorithm (pre-fetched will
% be all draws starting from `'firstPrefetch='`); to that end, a pool of
% parallel workers (using e.g. `matlabpool` from the Parallel Computing
% Toolbox) must be opened before calling `arwm`.
%
% With pre-fetching, all possible paths `'nStep='` steps ahead (i.e. all
% possible combinations of reject/accept) are pre-evaluated in parallel,
% and then the resulting path is selected. Adapation then occurs only every
% `'nStep='` steps, and hence the results will always somewhat differ from
% a serial run. Identical results can be obtained by turning down
% adaptation before pre-fetching starts, i.e. by setting `'lastAdapt='`
% smaller than `'firstPrefetch='` (and, obviously, by re-setting the random
% number generator).
% 
% References
% ===========
%
% # Brockwell, A.E., 2005. "Parallel Markov Chain Monte Carlo Simulation by
% Pre-Fetching," CMU Statistics Dept. Tech. Report 802.
%
% # Strid, I., 2009. "Efficient parallelisation of Metropolis-Hastings
% algorithms using a prefetching approach," SSE/EFI Working Paper Series in
% Economics and Finance No. 706.
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
opt = passvalopt('poster.arwm',varargin{:});

%--------------------------------------------------------------------------

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
    doPrepSave();
end

sgm = opt.initscale;
if opt.burnin < 1
    % Burn-in is a percentage.
    burnin = round(opt.burnin*NDraw);
else
    % Burn-in is the number of draws.
    burnin = opt.burnin;
end

if opt.lastAdapt<1
    % lastAdapt is a percentage.
    opt.lastAdapt = round(opt.lastAdapt*NDraw) ;
end

nDrawTotal = NDraw + burnin;
gamma = opt.gamma;
k1 = opt.adaptscale;
k2 = opt.adaptproposalcov;
targetAR = opt.targetar;

doChkParallel();

isAdaptiveScale = isfinite(gamma) && k1 > 0;
isAdaptiveShape = isfinite(gamma) && k2 > 0;
isAdaptive = isAdaptiveScale || isAdaptiveShape;

theta = This.initParam(:);
P = chol(This.initProposalCov).';
logPost = mylogpost(This,theta);

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

if opt.nstep>1
    % Minimize communication overhead:
    ThisPf = WorkerObjWrapper( This ) ;
    sPf = WorkerObjWrapper( s ) ;
end

j = 1;
while j <= nDrawTotal
    
    if j >= opt.firstPrefetch
        nStep = min(opt.nstep,1+nDrawTotal-j);
        nPath = 2^nStep;
    else
        nStep = 1;
        nPath = 1;
    end
    
    if nStep == 1
        
        % Serial implementation
        %-----------------------
        
        % Propose a new theta, and evaluate log posterior.
        u = randn(nPar,1);
        newTheta = theta + sgm*P*u;
        newLogPost = mylogpost(This,newTheta);
        
        % Generate random acceptance.
        randAcc = rand();
        
        doAcceptStore();
        j = j + 1;
        
    else
        
        % Parallel implementation
        %-------------------------
        
        % Number of steps, number of parallel paths.
                
        % Propose new thetas, evaluate log posteriors for all of them in parallel,
        % and pre-generate random acceptance.
        [thetaPf,logPostPf,randAccPf,uPf] = doPrefetch();
        
        % Find path through lattice prefetch; `pos0` is a zero-based position
        % beween `0` and `2^nsteps`.
        pos0 = 0;
        
        for iStep = 1 : nStep
            % New proposals.
            newPos0 = bitset(pos0,iStep);
            newTheta = thetaPf(:,1+newPos0);
            newLogPost = logPostPf(1+newPos0);
            randAcc = randAccPf(iStep);
            u = uPf(:,iStep);
            
            isAccepted = doAcceptStore();
            
            if isAccepted
                pos0 = newPos0;
            end
            j = j + 1;
            
        end
        
    end
end

FinalCov = P*P.';

% Nested functions.

%**************************************************************************
    function IsAccepted = doAcceptStore()
        % doAcceptStore  Accept or reject the current proposal, and store this
        % step.
        
        % Prob of new proposal being accepted; `newLogPost` can be `-Inf`, in which
        % case `alpha` is zero. If both `logPost` and `newLogPost` are `-Inf` the
        % inner max function returns `0` and the new proposal is never accepted.
        alpha = min(1,max(0,exp(newLogPost-logPost)));
        
        % Decide if we accept the new theta.
        IsAccepted = randAcc < alpha;

        if IsAccepted
            logPost = newLogPost;
            theta = newTheta;
        end
        
        isAdaptive = isAdaptive && j - burnin <= opt.lastAdapt;
        
        % Adapt the scale and/or proposal covariance.
        if isAdaptive
            doAdapt();
        end
        
        % Add the j-th theta to the chain unless it's still burn-in.
        if j > burnin
            count = count + 1;
            nAccepted = nAccepted + double(IsAccepted);
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
            % Save and reset.
            if count == opt.saveevery || (isSave && j == nDrawTotal)
                doSave();
                count = 0;
            end
        end
        
        % Update the progress bar or estimated time.
        if opt.progress
            update(progress,j/nDrawTotal);
        elseif opt.esttime
            update(eta,j/nDrawTotal);
        end
        
        function doSave()
            h5write(opt.saveas, ...
                '/theta',Theta,[1,SaveCount+1],size(Theta));
            h5write(opt.saveas, ...
                '/logPost',LogPost,[1,SaveCount+1],size(LogPost));
            SaveCount = SaveCount + size(Theta,2);
            n = nDrawTotal - j;
            if n == 0
                Theta = [];
                LogPost = [];
                AccRatio = [];
                Sgm = [];
            elseif n < nAlloc
                Theta = Theta(:,1:n);
                LogPost = LogPost(1:n);
                AccRatio = AccRatio(1:n);
                if isAdaptiveScale
                    Sgm = Sgm(:,1:n);
                end
            end
        end % doSave().
        
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
        
    end % doAcceptStore().

%**************************************************************************
    function doPrepSave()
        if isempty(opt.saveas)
            utils.error('poster', ...
                'The option ''saveas='' must be a valid file name.');
        end
        % Create an HDF5.
        h5create(opt.saveas,'/theta',[nPar,NDraw],'fillValue',NaN);
        h5create(opt.saveas,'/logPost',[1,NDraw],'fillValue',NaN);
        h5writeatt(opt.saveas,'/', ...
            'paramList',sprintf('%s ',This.paramList{:}));
        h5writeatt(opt.saveas,'/','nDraw',NDraw);
        h5writeatt(opt.saveas,'/','saveEvery',opt.saveevery');
    end % doPrepSave().

%**************************************************************************
    function [ThetaPf,LogPostPf,RandAccPf,uPf] = doPrefetch()
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  The wisdom behing the indexing in the prefetching array
        %
        %  starting from point 'curr_pt' we want to make n steps.  At each step we
        %  generate a random walk point from the current one and either accept the
        %  new point or reject the new point and keep the current one.  We assign
        %  to 'accept' the bit 1 and to 'reject' the bit 0.  The total number of
        %  possible points at the end of n steps is 2^n.  Each possible path is
        %  uniquely described by the ordered bits in the binary representation of a
        %  number between 0 and 2^n-1.  The right-most (least significant) bit
        %  represents the outcome at the first step, and so on moving to the left
        %  each step, until the left-most (most significant) bit represents the
        %  outcome at the n-th step.
        %
        %  E.g. for n=2 we have
        %                    00
        %                /       \
        %              00         01
        %            /    \     /    \
        %          00     10   01    11
        %          (0)    (2)  (1)   (3)    <-- index in the array minus one
        %
        %  A point with some intdex, r, was generated on the step, k, equal to the
        %  position of the left-most 1 bit in the binary representation of r.
        %  (Positions are counted from right to left)
        %  Points generated from this one will have indices derived from r by
        %  setting a bit further to the left to 1, up to and including bit in
        %  position n.
        %
        %  NOTE: this binary indexing gives values from 0 to 2^n-1.  Since in
        %  MATLAB indices are unit-based, we add one to get a valid MATLAB index.
        %
        %  Copyright (c) 2012-2013 Boyan Bejanov and the IRIS Solutions Team
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Pre-generate random increments. The increments are path-independent so
        % that we can reproduce the results of a no-prefetch algorithm (turning off
        % adaptation): in each step, a single unique random vector is used
        % independent of the history.
        %
        % Moreover, pre-generate a vector of random acceptance in the same sequence
        % of steps as in serial implementation.
        X = nan(nPar,nStep);
        RandAccPf = nan(1,nStep);
        uPf = nan(nPar,nStep);
        for iiStep = 1 : nStep
            uPf(:,iiStep) = randn(nPar,1);
            X(:,iiStep) = sgm*P*uPf(:,iiStep);
            RandAccPf(iiStep) = rand();
        end
        
        % Pre-allocate path-dependent end-points, nPath = 2^nStep.
        ThetaPf = nan(nPar,nPath);
        
        % Generate all possible paths.
        doPaths(theta,1,0);
        
        % Evaluate log posterior for each path.
        LogPostPf = nan(nPath,1);
        LogPostPf(1) = logPost;
        parfor iPath = 2 : nPath
            LogPostPf(iPath) = mylogpost(ThisPf.Value,ThetaPf(:,iPath)); %#ok<PFBNS>
        end
        
        function doPaths(Theta0,Step,PathSoFar)
            % Proposal rejected.
            thetaRej = Theta0;
            pathRej = PathSoFar;
            % Proposal accepted.
            thetaAcc = Theta0 + X(:,Step);
            pathAcc = bitset(PathSoFar,Step);
            if Step < nStep
                % Fork the paths.
                doPaths(thetaRej,Step+1,pathRej);
                doPaths(thetaAcc,Step+1,pathAcc);
            else
                % Store the end-point.
                ThetaPf(:,1+pathRej) = thetaRej;
                ThetaPf(:,1+pathAcc) = thetaAcc;
            end
        end
        
    end % doPrefetch().

%**************************************************************************
    function doChkParallel()
        if opt.firstPrefetch < nDrawTotal && opt.nstep > 1
            isPCT = license('test','distrib_computing_toolbox');
            if isPCT
                nWorkers = matlabpool('size');
                if nWorkers <= 1
                    utils.warning('poster', ...
                        'Prefetching without parallelism is pointless.');
                elseif nWorkers > 2^opt.nstep-1
                    utils.warning('poster', ...
                        'Some workers will be idle, consider increasing the number of prefetch steps.');
                elseif opt.nstep < log2(opt.nstep*(nWorkers+1))
                    utils.warning('poster', ...
                        'Sequential version will be faster. Consider decreasing the number of prefetch steps.');
                end
            else
                utils.warning('poster', ...
                    'Prefetching without parallelism is pointless.');
            end
        end
    end % doChkParallel().

end