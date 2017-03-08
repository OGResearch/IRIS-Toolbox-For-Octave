m = model('simple_SPBC.model') ;

% Unsolved model.
mInit = m ;

if exist('toSolve','var') && toSolve
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
  mInitSolved = m;
end