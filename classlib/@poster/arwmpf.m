function varargout = arwmpf(THIS,NDraw,varargin)
% arwmpf  Parallel adaptive random-walk Metropolis posterior simulator
% with prefetching
%
% Syntax
% =======
%
% [] = arwmpf(Pos,NDraw,...)
%
% Input arguments
% ================
%
% * `Pos` [ poster ] - Initialised posterior simulator object
%
% * `NDraw` [ numeric ] - Length of the chain not including burn-in
%
% Output arguments
% =================
%
% * `Theta` [ numeric ] MCMC chain with individual parameters in rows
%
% * `LogPost` [ numeric ] Vector of log posterior density (up to a
% constant) in each draw.
%
% Options
% ========
%
% * `'burnin='` [ numeric | *`0.10`* ] - Number of burn-in draws entered
% either as a percentage of total draws (between 0 and 1) or directly as a
% number (integer greater that one). Burn-in draws will be added to the
% requested number of draws `ndraw` and discarded after the posterior
% simulation.
%
% * `'gamma='` [ numeric | *`0.8`* ] - The rate of decay at which the scale
% and/or the proposal covariance will be adapted with each new draw.
%
% * `'initScale='` [ numeric | `1/3` ] - Initial scale factor by which the
% initial proposal covariance will be multiplied; the initial value will be
% adapted to achieve the target acceptance ratio.
%
% *`'targetAR='` [ numeric | *`0.234`* ] - Target acceptance ratio.
%
%%
% OUTPUTS:
%          sample   -- the sample
%          props    -- all proposed points
%          accept   -- logical array teh same length as props
%          p_logpdf -- the values of the target_logpdf at the props
%          qrw      -- the internal random-walk proposal structure -- for
%          debugging and development purposes
%
% INPUTS:
%          nlabs -- maximum number of labs in the parallel job
%          options.nsteps -- number of prefetching steps to make at a time
%          n       -- desired sample size
%          start   -- initial point of the chain
%          target_logpdf -- handle/m-function that computes the log density
%          of the target distribution
%          burnin  -- number of points to discard at the start of the chain
%          thin    -- keep one of every 'thin' points beyond the burnin
%          initial_qrw -- initial proposal distribution.  If present, this
%          structure must contain fileld 'n0'.  If 'n0' > 0 then it must
%          also contain a field 'sigma0', giving the initial covariance
%          matrix.  It may also contain a field 'theta0' giving the
%          original mean of the distribution.  in this case, 'n0' is the
%          assumed size of the sample from which 'theta0' and 'sigma0' were
%          estimated.
%
% -IRIS Toolbox
% -Copyright (c) 2012-2013 IRIS Solutions Team and Boyan Bejanov 

% Validate required inputs.
pp = inputParser();
pp.addRequired('Pos',@(x) isa(x,'poster'));
pp.addRequired('NDraw',@isnumericscalar);
pp.parse(THIS,NDraw);

% Parse options.
options = passvalopt('poster.arwmpf',varargin{:});

if options.burnin<1
	% options.burnin is a percentage
	options.burnin=floor(NDraw*options.burnin);
end

if options.n0==-1
    % set default value for sample size of proposal distribution
    options.n0=0.1*NDraw;
end

if options.nlabs==1
	% sequential version for debugging
	varargout = cell(nargout, 1);
	[varargout{:}] = mainWork(THIS,NDraw,options);
	return;
else
	% parallel version: create parcluster object and job
	sched = parcluster(options.profile);
	job = createCommunicatingJob(sched,'NumWorkersRange',options.nlabs*[1 1]);
end

try
	% try to run parallel job, in case of exception throw an error and
	% destroy the job
	mpiSettings('MessageLogging', 'on');
	
	tsk = createTask(job, @mainWork, nargout, {THIS,NDraw,options});
% 	set(tsk, 'CaptureCommandWindowOutput', 1);
	
	submit(job);
	wait(job, 'running');
	
	tsk = get(job, 'Tasks');
	tt = tic;
	while ~wait(job, 'finished', 5)
		fprintf('Waiting for job to finish : %g sec.\n', toc(tt));
	end
	
	err_tsk = find(~cellfun(@isempty, get(tsk, 'Error')));
	fprintf('Job finished : %g sec.  %g\n', toc(tt), job.UserData);
	if ~isempty(err_tsk)
		fprintf('%d have errors\n', length(err_tsk));
		rethrow(tsk(err_tsk(1)).Error);
	end
	
	for i=1:length(tsk)
		disp( get(tsk(i), 'CommandWindowOutput') )
	end
	varargout = tsk(1).OutputArguments;
	if nargout > 5
		for i=2:length(tsk)
			vv = tsk(i).OutputArguments;
			varargout{6} = [varargout{6} vv{6}];
		end
	end
	destroy(job);
catch me
	destroy(job);
	rethrow(me);
end %try

end %arwmpf

%**************************************************************************
function [sample, points, accept, p_logpdf, ret_qrw, tm] = mainWork(...
	THIS,NDraw,options)

tm = struct('tt', tic, 'ct', 0, 'pwt', 0, 'swt', 0, 'ut', 0);
% tt = total time
% ct = communications time (reasonably measured from labindex 1)
% pwt = time spent in parallel work regions
% swt = time spent in sequential work regions
% ut = time spent in update_qrw (as measured from the caller)

% if not(exist('initial_qrw', 'var')) || isempty(initial_qrw)
% 	initial_qrw = struct('n0', 0, ...
% 		'theta0', zeros(size(start)), 'sigma0', zeros(length(start)));
% end

nPar = length(THIS.paramList);
nDrawTotal = NDraw * options.thin + options.burnin;
s = mylogpoststruct(THIS);

global qrw
qrw = struct();

if labindex == 1
	% master worker
	sample = zeros(nDrawTotal,nPar);
	points = zeros(nDrawTotal, nPar);
	accept = false(nDrawTotal,1);
	p_logpdf = -inf(nDrawTotal, 1);
	ret_qrw = {};
	
	curr = THIS.initParam(:).';
	lp_curr = mylogpost(THIS,vec(curr),s);

	% Initialize global variables
	% data for qrw proposal
	qrw.alpha = 0.7;
	qrw.beta = 0.9;
	qrw.kappa1 = 2.38^2/nPar;
	qrw.kappa2 = 9*qrw.kappa1;
	qrw.kappa3 = 0.1^2/nPar;
	qrw.n0 = reshape(options.n0,1,1);
	qrw.theta0 = reshape(THIS.initParam, 1, nPar);
	qrw.sigma0 = options.initscale*reshape(THIS.initProposalCov, nPar, nPar);
	qrw.n = 1;

	% initial proposal distribution
	qrw.theta = qrw.theta0;
	qrw.sigma = qrw.sigma0;
	qrw.Csigma0 = chol(qrw.sigma0);
	qrw.Csigma = qrw.Csigma0;

	qrw.acc_rates = zeros(nDrawTotal, 1);
	qrw.acc_full = false;
	qrw.acc_gamma = options.gamma; % 0.8;
	qrw.acc_target = options.targetar; % 0.234 + (0.5-0.234)*max(0, 6-nPar)/5;
	qrw.acc_pt = 0;
	qrw.lsgm2 = 0;
	qrw.AR_alpha = zeros(nDrawTotal,1);
	qrw.AR_sgm2 = zeros(nDrawTotal,1);
end

global pref_pts pref_lp
pref_size = intpow(2, options.nsteps);
pref_pts = zeros(pref_size, nPar);
pref_lp = zeros(pref_size, 1);

pref_alpha = zeros(options.nsteps, 1);
step = 0;
while step < nDrawTotal
	if labindex == 1
		jb = getCurrentJob;
		if ~isempty(jb)
			set(jb, 'UserData', step);
		end
		
		ftm = qrw_pref_rand_1(curr, options.nsteps);
		tm.swt = tm.swt + ftm.tt;
	end
	
	ftm = calc_pref_logpdf(THIS,s);
	tm.ct = tm.ct + ftm.ct;
	tm.pwt = tm.pwt + ftm.wt;
		
	if labindex > 1
		step = step + options.nsteps;
		continue;
	end
	
	foo = tic;
	curr_r = 0;
	pref_alpha(:) = 1;
	for b=1:options.nsteps
		% see comments below for explanation of the indexing of the
		% prefetched arrays (curr_r, prop_r)
		step = step + 1;
		if step > nDrawTotal, break; end
		prop_r = bitset(curr_r, b);
		prop = pref_pts(1+prop_r, :);
		lp_prop = pref_lp(1+prop_r);
		log_alpha = lp_prop - lp_curr;
		
		if log_alpha < 0, pref_alpha(b) = exp(log_alpha); end
		qrw.AR_alpha(step) = pref_alpha(b);
		qrw.AR_sgm2(step) = exp(qrw.lsgm2/2);
		
		points(step, :) = prop;
		p_logpdf(step) = lp_prop;
		log_rand = log(rand);
		if log_rand < log_alpha
			accept(step) = true;
			curr = prop;
			lp_curr = lp_prop;
			curr_r = prop_r;
		else
			accept(step) = false;
		end
		sample(step,:) = curr;
	end
	if step < nDrawTotal,
		bar = tic;
		update_qrw(sample(step-options.nsteps+(1:options.nsteps),:), pref_alpha);
		tm.ut = tm.ut + toc(bar);
	end
	
	tm.swt = tm.swt + toc(foo);
end

if labindex == 1
	sample(1:options.burnin,:) = [];
	sample = sample(1:options.thin:end,:);
	ret_qrw = [ret_qrw, {qrw}];
else
	sample = [];
	points = [];
	accept = [];
	p_logpdf = [];
	ret_qrw = [];
end

tm.tt = toc(tm.tt);
end

%**************************************************************************
function update_qrw(new_points, new_rates)
global qrw;
ni = size(new_points, 1);
old_theta = qrw.theta;
if qrw.n0 == 0
	qrw.theta = (qrw.n*old_theta + sum(new_points,1)) / (qrw.n+ni);
	[~,C] = qr([sqrt(qrw.n-1)*qrw.Csigma; ...
		sqrt(qrw.n)*old_theta; ...
		new_points ...
		], 0);
	C = diag(sign(diag(C))) * C; % keep diagonal entries non-negative
	C = cholupdate(C, sqrt(qrw.n+ni)*qrw.theta.', '-');
	qrw.Csigma = C / sqrt(qrw.n+ni-1);
	qrw.sigma = (qrw.Csigma.'*qrw.Csigma);
elseif  ~isinf(qrw.n0)
	qrw.theta = (qrw.n0*qrw.theta0+qrw.n*old_theta + sum(new_points,1)) ...
		/ (qrw.n+ni+qrw.n0);
	[~,C] = qr([sqrt(qrw.n-1)*qrw.Csigma; ...
		sqrt(qrw.n0)*qrw.Csigma0; ...
		sqrt(qrw.n)*old_theta; ...
		new_points ...
		], 0);
	C = diag(sign(diag(C))) * C; % keep diagonal entries non-negative
	C = cholupdate(C, sqrt(qrw.n+ni)*qrw.theta.', '-');
	qrw.Csigma = C / sqrt(qrw.n+ni+qrw.n0-1);
	qrw.sigma = (qrw.Csigma.'*qrw.Csigma);
else
end
qrw.n = qrw.n + ni;
% now update the scale to keep the rate at target
ind = 1+mod(qrw.acc_pt-1+(1:ni), length(qrw.acc_rates));
qrw.acc_rates(ind) = new_rates;
if (~qrw.acc_full) && any(ind == length(qrw.acc_rates)),
	qrw.acc_full = true;
end
qrw.acc_pt = ind(end);
if qrw.acc_full
	rate = mean(qrw.acc_rates);
	coef = length(qrw.acc_rates)^(-qrw.acc_gamma);
else
	rate = mean(qrw.acc_rates(1:qrw.acc_pt));
	coef = qrw.acc_pt^(-qrw.acc_gamma);
end
qrw.lsgm2 = 0; % qrw.lsgm2 + coef*(rate - qrw.acc_target);
end

%**************************************************************************
function propx = qrw_rand(n, this)
global qrw
if not(0<=qrw.alpha && qrw.alpha<=1 && 0<=qrw.beta && qrw.beta<=1)
	error('qrw_rand: alpha and beta must be in [0,1]');
end
k = size(this,2);
propx = zeros(n, k);
if n == 0
	return
end
phi = exp(qrw.lsgm2/2);
% propx = mvn_rand(n, this, phi*qrw.sigma);
% return;

pr = [qrw.alpha*qrw.beta, (1-qrw.alpha)*qrw.beta, 1-qrw.beta];
bin = multinomial_rand(n, pr);
n1 = sum(bin==1);
if n1>0
	propx(bin==1,:) = mvn_rand(n1, this, phi*qrw.kappa1*qrw.sigma);
end
n2 = sum(bin==2);
if n2>0
	propx(bin==2,:) = mvn_rand(n2, this, phi*qrw.kappa2*qrw.sigma);
end
n3 = sum(bin==3);
if n3>0
	propx(bin==3,:) = mvn_rand(n3, this, phi*qrw.kappa3*eye(k));
end
end  % function



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

%**************************************************************************
function tm = qrw_pref_rand_1(root_pt, nsteps)
global pref_pts
tt = tic;
recurse(root_pt, 0, 0);
tm = struct('tt', toc(tt));
return

	function recurse(pt, r, k)
		pref_pts(1+r,:) = pt;
		if k==nsteps, return; end;
		pts = qrw_rand(nsteps-k, pt);
		shift = 2^k;
		for b=1:(nsteps-k)
			rr = r + shift;
			recurse(pts(b,:), rr, k+b);
			shift = 2*shift;
			% fprintf('setting point %03d from point %03d\n', rr, r);
		end
	end
end


%**************************************************************************
function tm = calc_pref_logpdf(THIS,s)
global pref_pts pref_lp
len_plp = length(pref_lp);
assert(size(pref_pts,1) == len_plp);
tt = tic;
if labindex == 1
	foo = tic;
	for i=2:numlabs
		labSend(pref_pts(i:numlabs:len_plp, :), i);
	end
	ct = toc(foo);
	foo = tic;
	for k=1:numlabs:len_plp
		pref_lp(k) = mylogpost(THIS,vec(pref_pts(k,:)),s);
	end
	wt = toc(foo);
	foo = tic;
	for i=2:numlabs
		[data, sender] = labReceive('any');
		% fprintf('sender %03d : expected %d,  received %d\n', sender,...
		%     length(data), length(sender:numlabs:len_plp));
		pref_lp(sender:numlabs:len_plp) = data;
	end
	ct = ct + toc(foo);
else
	foo = tic;
	pts = labReceive(1);
	ct = toc(foo);
	foo = tic;
	lp = zeros(size(pts,1),1);
	for k=1:length(lp)
		lp(k) = target_lp(pts(k,:));
	end
	wt = toc(foo);
	foo = tic;
	labSend(lp, 1);
	ct = ct + toc(foo);
end
tm = struct('tt', toc(tt), 'ct', ct, 'wt', wt);
end

function b = intpow(a, n)
%% Computes an integer power efficiently.
%     b = intpow(a,n)
%  returns b = a.^n where n must be integer
%

% Boyan Bejanov (bejb@bankofcanada.ca)
% Sept. 2012

n = int32(n);
b = ones(size(a));
if n == 0
    b(a==0) = nan(1);
    return
elseif n < 0
    a = 1./a;
    n = -n;
end
while n>0
    k = idivide( n, int32(2) );
    if 2*k-n %#ok<BDLOG>
        b(:) = b.*a;
    end
    n = k;
    a(:) = a.^2;
end
end

function bin = multinomial_rand(n, pr)
cs = cumsum(pr(:).'); cs = cs / cs(end);
bin = 1+sum( bsxfun(@gt, rand(n,1), cs), 2);
return
end

function data = mvn_rand(num, mu, sigma, flag)
%% Generate a random sample from multivariate normal distribution
%    data = mvn_rand(num, mu, sigma)
%
% Boyan Bejanov (bejb@bankofcanada.ca)
% Sept. 2012

n = num(1);
mu = mu(:).';
k = length(mu);
sigma = reshape(sigma, k,k);
if (nargin < 4) || (~strcmpi(flag, 'chol'))
    U = chol(sigma);
else
    U = sigma;
end
% U = chol(sigma);   %%  U' * U = sigma;
% data = mu(ones(1,n),:) + randn(n,k)*chol(sigma);
data = bsxfun(@plus, randn(n,k)*U, mu);
end

function out=vec(in)
out=in(:);
end