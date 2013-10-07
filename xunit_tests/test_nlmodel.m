function test_nlmodel
initTestSuite;
end

function m=setup
m=model('simple_SPBC.model');
end

function test_get(obj)
assertEqual({'Ey'    'Ep'    'Ea'    'Er'    'Ew'},get(obj,'exList'));
assertEqual({'Short'    'Infl'    'Growth'    'Wage'},get(obj,'yVector'));
assertEqual({'Mp'    'Mw'},get(obj,'eyList'));
plist={'alpha' 'beta' 'gamma' 'delta' 'k' 'pi' 'eta' 'psi' 'chi' 'xiw' 'xip' 'rhoa' 'rhor' 'kappap' 'kappan' 'Short_' 'Infl_' 'Growth_' 'Wage_' 'std_Mp' 'std_Mw' 'std_Ey' 'std_Ep' 'std_Ea' 'std_Er' 'std_Ew'}';
assertEqual(plist,fields(get(obj,'params')));
end

function test_isname(obj)
assertEqual(isname(obj,'alpha'),true);
assertEqual(isname(obj,'alph'),false);
end

function test_isnan(obj)
assertEqual(isnan(obj),true);
end

function test_issolved(obj)
assertEqual(issolved(obj),false);
end

function test_alter(obj)
assertEqual(length(alter(obj,3)),3);
end

function test_sstate(obj) %#ok<*DEFNU>
assertEqual(chksstate(doSsSolve(obj)),true);
end

function test_estimate(obj)

obj=doSsSolve(obj);

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

td=load('test_nlmodel_data.mat');
[est,pos,C,H,mest,v,~,~,delta,Pdelta] = ...
    estimate(obj,td.d,td.starthist:td.endhist,E, ...
    'filter=',filteropt,'optimset=',{'display=','off'},...
    'tolx=',1e-8,'tolfun=',1e-8,...
    'sstate=',false,'solve=',true,'nosolution=','penalty','chksstate=',false); %also test some default options

cmp=load('test_nlmodel_estimation');
pnames=fields(est);
for iName = 1 : numel(pnames)
    assertElementsAlmostEqual(cmp.est.(pnames{iName}),est.(pnames{iName}),'relative',1e-3);
end
assertElementsAlmostEqual(cmp.C,C,'relative',0.1);
fnames=fields(cmp.delta);
for ii=1 : numel(fnames)
    assertElementsAlmostEqual(cmp.delta.(fnames{ii}),delta.(fnames{ii}),'relative',1e-2);
end
assertElementsAlmostEqual(double(cmp.Pdelta),double(Pdelta),'relative',1e-3);

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
end

function obj=doSsSolve(obj)
obj.alpha = 1.03^(1/4);
obj.beta = 0.985^(1/4);
obj.gamma = 0.60;
obj.delta = 0.03;
obj.pi = 1.025^(1/4);
obj.eta = 6;
obj.k = 10;
obj.psi = 0.25;
obj.chi = 0.85;
obj.xiw = 60;
obj.xip = 300;
obj.rhoa = 0.90;
obj.rhor = 0.85;
obj.kappap = 3.5;
obj.kappan = 0;
obj.Short_ = 0;
obj.Infl_ = 0;
obj.Growth_ = 0;
obj.Wage_ = 0;
obj.std_Mp = 0;
obj.std_Mw = 0;
obj.std_Ea = 0.001;

obj = sstate(obj,'growth=',true,'blocks=',true,'display=','off');
end
