mInit = model('testAssign.model');

expSstate = struct( ...
    'x',[0,0.5], ...
    'y',[1,1], ...
    'e',[0,0], ...
    'u',[0,0], ...
    'alp',[2,2], ...
    'bet',[3,3] ...
    );

expStd = struct( ...
    'std_e',[10,10.5], ...
    'std_u',[20,20] ...
    );

m = mInit;
m = alter(m,2);
m = assign(m,expSstate);
m = assign(m,expStd);
actSstate = get(m,'sstate');
actStd = get(m,'std');
myassert(actSstate,expSstate);
myassert(actStd,expStd);

m = mInit;
m = alter(m,2);
m = assign(m,'x',[0,0.5],'y',1,'alp',2,'bet',3, ...
    'std_e',[10,10.5],'std_u',20);
actSstate = get(m,'sstate');
actStd = get(m,'std');
myassert(actSstate,expSstate);
myassert(actStd,expStd);

n = mInit;
n = alter(n,2);
n = assign(n,m);
actSstate = get(n,'sstate');
actStd = get(n,'std');
myassert(actSstate,expSstate);
myassert(actStd,expStd);

