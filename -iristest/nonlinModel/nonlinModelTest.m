function Tests = nonlinModelTest()

Tests = functiontests(localfunctions) ;

end


%**************************************************************************
function setupOnce(This) %#ok<*DEFNU>

m = model('simple_SPBC.model') ;

% Unsolved model.
This.TestData.model = m ;

m.alpha = 1.03^(1/4);
m.beta = 0.985^(1/4);
m.gamma = 0.60;
m.delta = 0.03;
m.pi = 1.025^(1/4);
m.eta = 6;
m.k = 10;
m.psi = 0.25;
m.chi = 0.85;
m.xiw = 60;
m.xip = 300;
m.rhoa = 0.90;
m.rhor = 0.85;
m.kappap = 3.5;
m.kappan = 0;
m.Short_ = 0;
m.Infl_ = 0;
m.Growth_ = 0;
m.Wage_ = 0;
m.std_Mp = 0;
m.std_Mw = 0;
m.std_Ea = 0.001;
m = sstate(m,'growth=',true,'blocks=',true,'display=','off');
m = solve(m);

% Solved model.
This.TestData.solvedModel = m;

end % setupOnce()


%**************************************************************************
function testGet(This)

m = This.TestData.model ;

actual = get(m, 'exList') ;
expected = {'Ey', 'Ep', 'Ea', 'Er', 'Ew'} ;
assertEqual(This, actual, expected) ;

actual = get(m, 'yList');
expected = {'Short', 'Infl', 'Growth', 'Wage'} ;
assertEqual(This, actual, expected) ;

actual = get(m, 'eyList');
expected = {'Mp', 'Mw'};
assertEqual(This, actual, expected) ;

actual = get(m, 'pList') ;
expected = {'alpha', 'beta', 'gamma', 'delta', 'k', 'pi', 'eta', 'psi', ...
    'chi', 'xiw', 'xip', 'rhoa', 'rhor', 'kappap', 'kappan', 'Short_', ...
    'Infl_', 'Growth_', 'Wage_'} ;
assertEqual(This, actual, expected) ;

actual = get(m,'stdList') ;
expected = {'std_Mp', 'std_Mw', 'std_Ey', 'std_Ep', 'std_Ea', 'std_Er', ...
    'std_Ew'} ;
assertEqual(This, actual, expected) ;

end % testGet()


%**************************************************************************
function testIsname(This)

m = This.TestData.model ;
assertEqual(This, isname(m, 'alpha'), true) ;
assertEqual(This, isname(m, 'alph'), false) ;

end % testIsname()


%**************************************************************************
function testIsnan(This)
    
m = This.TestData.model ;
assertEqual(This, isnan(m), true) ;

end % testIsnan()


%**************************************************************************
function testIssolved(This)

m = This.TestData.model ;
mm = This.TestData.solvedModel ;

assertEqual(This, issolved(model()), false) ;
assertEqual(This, issolved(m), false) ;
assertEqual(This, issolved(mm), true) ;

end % isSolved()


%**************************************************************************
function testAlter(This)

m = This.TestData.model ;
assertEqual(This, length(alter(m, 3)), 3) ;
assertEqual(This, length(m([1,1,1])), 3) ;

end % testAlter()


%**************************************************************************
function testChkstate(This)

m = This.TestData.model ;
mm = This.TestData.solvedModel ;

assertEqual(This, issolved(model()), false) ;
assertEqual(This, issolved(m), false) ;
assertEqual(This, chksstate(m,'error=', false, 'warning=', false), false) ;
assertEqual(This, issolved(mm), true) ;
assertEqual(This, chksstate(mm,'error=', false, 'warning=', false), true) ;

end % testChksstate()


%**************************************************************************
function testEstimate(This)

m = This.TestData.solvedModel;

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
    assertEqual(This, actual, expected, 'relTol', 1e-3) ;
end
%assertEqual(This, cmp.C, C, 'relTol', 0.1) ;

fNames = fields(cmp.delta) ;
for ii = 1 : numel(fNames)
    actual = delta.(fNames{ii}) ;
    expected = cmp.delta.(fNames{ii}) ;
    assertEqual(This, actual, expected, 'relTol', 1e-2) ;
end
assertEqual(This, double(Pdelta), double(cmp.Pdelta), 'relTol', 1e-3) ;

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

end % testEstimate
