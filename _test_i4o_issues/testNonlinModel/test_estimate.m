toSolve = true;

try
  setup4tests;
catch err
  clear toSolve m mInit mInitSolved
  if ~isempty(strfind(err.message,'handles to nested functions are not yet supported'))
    error('expected error:: no possibility to solve non-linear models in iris4octave');
  else
    rethrow(err);
  end
end

m = mInitSolved;

E = struct();
E.chi = {NaN,  0.5,  0.95,  logdist.normal(0.85,0.025)};
E.xiw = {NaN,  30,  1000,  logdist.normal(60,50)};
E.xip = {NaN,  30,  1000,  logdist.normal(300,50)};
E.rhor = {NaN,  0.10,  0.95,  logdist.beta(0.85,0.05)};
E.kappap = {NaN,  1.5,  10,  logdist.normal(3.5,1)};
E.kappan = {NaN,  0,  1, logdist.normal(0,0.2)};
E.std_Ep = {0.01,  0.001,  0.10,  logdist.invgamma(0.01,Inf)};
E.std_Ew = {0.01,  0.001,  0.10,  logdist.invgamma(0.01,Inf)};
E.std_Ea = {0.001,  0.0001,  0.01,  logdist.invgamma(0.001,Inf)};
E.std_Er = {0.005,  0.001,  0.10,  logdist.invgamma(0.005,Inf)};
E.corr_Er__Ep = {0,  -0.9,  0.9,  logdist.normal(0,0.5)};

filteropt = { ...
    'outoflik=',{'Short_','Infl_','Growth_','Wage_'}, ...
    'relative=',true, ...
    };

td = load('nonlinModelData.mat');
[est,pos,C,~,~,~,~,~,delta,Pdelta] = ...
    estimate(m,td.d,td.starthist:td.endhist,E, ...
    'filter=',filteropt,'optimset=',{'display=','off'},...
    'tolx=',1e-8,'tolfun=',1e-8,...
    'sstate=',false,'solve=',true,'nosolution=','penalty', ...
    'chksstate=',false); %also test some default options

cmp = load('nonlinModelEstimation.mat') ;
pNames = fields(est) ;
for iName = 1 : numel(pNames)
    actual = est.(pNames{iName}) ;
    expected = cmp.est.(pNames{iName}) ;
    rel = actual./expected;
    myassert(rel, ones(size(rel)), 1e-3) ;
end
%rel = cmp.C./C;
%myassert(rel, ones(size(rel)), 0.1) ;

fNames = fields(cmp.delta) ;
for ii = 1 : numel(fNames)
    actual = delta.(fNames{ii}) ;
    expected = cmp.delta.(fNames{ii}) ;
    rel = actual./expected;
    myassert(rel, ones(size(rel)), 1e-2) ;
end
rel = double(cmp.Pdelta)./double(Pdelta);
myassert(rel, ones(size(rel)), 1e-3) ;

%{
if license('test','distrib_computing_toolbox') 
    % test prefetching
    if matlabpool('size')<2
        matlabpool open local 2
    end
    N=60;
    rng(0);
    [thetaP,logpostP,arP] = arwm(pos,N, ...
        'progress=',false,'burnin=',0,'nStep=',2,'firstPrefetch=',1,'lastAdapt=',1);
    matlabpool close force
    
    rng(0);
    [thetaS,logpostS,arS] = arwm(pos,N, ...
        'progress=',false,'burnin=',0,'nStep=',1,'lastAdapt=',1);
    
    assertElementsAlmostEqual(thetaP,thetaS);
    assertElementsAlmostEqual(logpostP,logpostS);
    assertElementsAlmostEqual(arP,arS);
end
%}