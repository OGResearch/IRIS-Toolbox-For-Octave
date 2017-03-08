mInit = model('testAssign.model');

expSstate = struct( ...
    'x',0, ...
    'y',1, ...
    'e',0, ...
    'u',0, ...
    'alp',2, ...
    'bet',3 ...
    );

expStd = struct( ...
    'std_e',10, ...
    'std_u',20 ...
    );

m = mInit;
m.x = 0;
m.y = 1;
m.alp = 2;
m.bet = 3;
m.std_e = 10;
m.std_u = 20;
actSstate = get(m,'sstate');
actStd = get(m,'std');
myassert(actSstate,expSstate);
myassert(actStd,expStd);

m = mInit;
m = assign(m,expSstate);
m = assign(m,expStd);
actSstate = get(m,'sstate');
actStd = get(m,'std');
myassert(actSstate,expSstate);
myassert(actStd,expStd);

m = mInit;
m = assign(m,'x',0,'y',1,'alp',2,'bet',3,'std_e',10,'std_u',20);
actSstate = get(m,'sstate');
actStd = get(m,'std');
myassert(actSstate,expSstate);
myassert(actStd,expStd);

m = mInit;
m = assign(m,'x',0,'y',1,'alp',2,'bet',3,'std_e',10,'std_u',20);
actSstate = get(m,'sstate');
actStd = get(m,'std');
myassert(actSstate,expSstate);
myassert(actStd,expStd);

m = mInit;
m = assign(m,'-level','x',0,'y',1,'alp',2,'bet',3,'std_e',10,'std_u',20);
actSstate = get(m,'sstate');
actStd = get(m,'std');
myassert(actSstate,expSstate);
myassert(actStd,expStd);