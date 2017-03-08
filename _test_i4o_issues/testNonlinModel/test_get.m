toSolve = false;
setup4tests;

m = mInit ;

actual = get(m, 'exList') ;
expected = {'Ey', 'Ep', 'Ea', 'Er', 'Ew'} ;
myassert(actual, expected) ;

actual = get(m, 'yList');
expected = {'Short', 'Infl', 'Growth', 'Wage'} ;
myassert(actual, expected) ;

actual = get(m, 'eyList');
expected = {'Mp', 'Mw'};
myassert(actual, expected) ;

actual = get(m, 'pList') ;
expected = {'alpha', 'beta', 'gamma', 'delta', 'k', 'pi', 'eta', 'psi', ...
    'chi', 'xiw', 'xip', 'rhoa', 'rhor', 'kappap', 'kappan', 'Short_', ...
    'Infl_', 'Growth_', 'Wage_'} ;
myassert(actual, expected) ;

actual = get(m,'stdList') ;
expected = {'std_Mp', 'std_Mw', 'std_Ey', 'std_Ep', 'std_Ea', 'std_Er', ...
    'std_Ew'} ;
myassert(actual, expected) ;