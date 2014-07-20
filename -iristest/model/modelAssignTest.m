function Tests = modelAssignTest()
Tests = functiontests(localfunctions);
end
%#ok<*DEFNU>


%**************************************************************************


function setupOnce(This)
This.TestData.Model = model('testAssign.model');
end % setupOnce()


%**************************************************************************


function testBasicAssign(This)

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

m = This.TestData.Model;
m.x = 0;
m.y = 1;
m.alp = 2;
m.bet = 3;
m.std_e = 10;
m.std_u = 20;
actSstate = get(m,'sstate');
actStd = get(m,'std');
assertEqual(This,actSstate,expSstate);
assertEqual(This,actStd,expStd);

m = This.TestData.Model;
m = assign(m,expSstate);
m = assign(m,expStd);
actSstate = get(m,'sstate');
actStd = get(m,'std');
assertEqual(This,actSstate,expSstate);
assertEqual(This,actStd,expStd);

m = This.TestData.Model;
m = assign(m,'x',0,'y',1,'alp',2,'bet',3,'std_e',10,'std_u',20);
actSstate = get(m,'sstate');
actStd = get(m,'std');
assertEqual(This,actSstate,expSstate);
assertEqual(This,actStd,expStd);

m = This.TestData.Model;
m = assign(m,'x',0,'y',1,'alp',2,'bet',3,'std_e',10,'std_u',20);
actSstate = get(m,'sstate');
actStd = get(m,'std');
assertEqual(This,actSstate,expSstate);
assertEqual(This,actStd,expStd);

m = This.TestData.Model;
m = assign(m,'-level','x',0,'y',1,'alp',2,'bet',3,'std_e',10,'std_u',20);
actSstate = get(m,'sstate');
actStd = get(m,'std');
assertEqual(This,actSstate,expSstate);
assertEqual(This,actStd,expStd);

end % testBasicAssign()


%**************************************************************************


function testAltAssign(This)

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

m = This.TestData.Model;
m = alter(m,2);
m = assign(m,expSstate);
m = assign(m,expStd);
actSstate = get(m,'sstate');
actStd = get(m,'std');
assertEqual(This,actSstate,expSstate);
assertEqual(This,actStd,expStd);

m = This.TestData.Model;
m = alter(m,2);
m = assign(m,'x',[0,0.5],'y',1,'alp',2,'bet',3, ...
    'std_e',[10,10.5],'std_u',20);
actSstate = get(m,'sstate');
actStd = get(m,'std');
assertEqual(This,actSstate,expSstate);
assertEqual(This,actStd,expStd);

n = This.TestData.Model;
n = alter(n,2);
n = assign(n,m);
actSstate = get(n,'sstate');
actStd = get(n,'std');
assertEqual(This,actSstate,expSstate);
assertEqual(This,actStd,expStd);

end % testAltAssign()

