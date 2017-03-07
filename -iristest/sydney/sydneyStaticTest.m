function Tests = sydneyStaticTest()

%#ok<*DEFNU>
Tests = functiontests(localfunctions) ;

end


%**************************************************************************


function testShift(This)
eqtn = 'x1m5 * log(x2p10) + x3 / x99m0 + x100p1';
actEqtn0 = sydney.myshift(eqtn,0,true(1,100));
actEqtnM2 = sydney.myshift(eqtn,-2,true(1,100));
actEqtnP5 = sydney.myshift(eqtn,+5,true(1,100));

expEqtn0 = 'x1m5 * log(x2p10) + x3 / x99m0 + x100p1';
expEqtnM2 = 'x1m7 * log(x2p8) + x3m2 / x99m2 + x100m1';
expEqtnP5 = 'x1 * log(x2p15) + x3p5 / x99p5 + x100p6';

assertEqual(This,actEqtn0,expEqtn0);
assertEqual(This,actEqtnM2,expEqtnM2);
assertEqual(This,actEqtnP5,expEqtnP5);
end
