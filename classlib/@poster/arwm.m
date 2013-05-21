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
if opt.nsteps==1
	for j = 1 : nDrawTotal
		% Propose a new theta.
		[newTheta,u]=propNew(theta,1);
		
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
			doAdapt(u);
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
else
	% parallel version
	if license('test','distrib_computing_toolbox')
		if matlabpool('size')==1
			doParallelWarn();
		end
		doParallelWarn();
	end
	
	% number of likelihood evaluations per prefetch step
	nLike = 2^opt.nsteps-1;
	logpostPf = NaN(nLike,1);
	j = 0;
	
	while j < nDrawTotal
		% Propose a new thetas for lattice prefetch, store innovations for
		% adaptation
		[thetaPf, uPf]=propNewPf(theta, nd);
		
		% Evaluate log posterior over pattice (heavy lifting is done in
		% parallel)
		parfor ii=1:nLike
			logpostPf(ii) = mylogpost(This, thetaPf(:,ii+1), s);
		end
		
		% Find path through lattice prefetch
		curr_r = 0;
		for bit=1:opt.nsteps
			j = j + 1;
			
			% accept/reject
			prop_r = bitset(curr_r, bit);
			alpha = min(1,exp(logpostPf(prop_r)-logPost));
			prop = thetaPf(:,1+prop_r);
			accepted = rand() <= alpha;
			if accepted
				logPost = logpostPf(prop_r);
				theta = thetaPf(:,1+prop_r);
			end
			
			% adapt
			if isAdaptive
				doAdapt(uPf(:,1+prop_r));
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
			end % if j > burnin
		end % for bit=1:opt.nsteps

		% Update the progress bar or estimated time.
		if opt.progress
			update(progress,j/nDrawTotal);
		elseif opt.esttime
			update(eta,j/nDrawTotal);
		end
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
	function doAdapt(u)
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

%**************************************************************************
	function [pref_pts,u_arr] = propNewPf(root_pt, npref)
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
		
		recurse(root_pt, zeros(size(root_pt)), 0, 0);
		return
		
		function recurse(pt, uu, r, k)
			pref_pts(1+r,:) = pt;
			u_arr(1+r,:) = uu;
			if k==npref, return; end;
			[pts,uu] = propNew(pt,npref-k);
			shift = 2^k;
			for b=1:(npref-k)
				%fprintf('setting point %03d from point %03d\n', rr, r);
				rr = r + shift;
				recurse(pts(b,:), uu(b,:), rr, k+b);
				shift = 2*shift;
			end
		end
	end % propNewPf();

%**************************************************************************
	function [newTheta,u]=propNew(pt,nd)
		% Propose new points conditional on current point in lattice.
		u = randn(nPar,nd);
		newTheta = bsxfun(@plus,pt,sgm*P*u);
	end % propNew();

%**************************************************************************
	function doParallelWarn()
		utils.warning('poster/arwm()','Prefetching without parallelism is pointless.');
	end % doParallelWarn();


end

