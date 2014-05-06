function Tests = fragileTest()

Tests = functiontests(localfunctions);

end
%#ok<*DEFNU>


%**************************************************************************


function testProtectBrackets(This)

expTxt = file2char('testFragile.txt');
expRemoved = file2char('testFragile_removedBrackets.txt');

f = fragileobj(expTxt);
[c,f] = protectbrackets(expTxt,f);
actRemoved = cleanup(c,f);
actTxt = restore(c,f);

assertEqual(This,actTxt,expTxt);
assertEqual(This,actRemoved,expRemoved);

end % testProtectBrackets()


%**************************************************************************


function testProtectBraces(This)

expTxt = file2char('testFragile.txt');
expRemoved = file2char('testFragile_removedBraces.txt');

f = fragileobj(expTxt);
[c,f] = protectbraces(expTxt,f);
actRemoved = cleanup(c,f);
actTxt = restore(c,f);

assertEqual(This,actTxt,expTxt);
assertEqual(This,actRemoved,expRemoved);

end % testProtectBraces()


%**************************************************************************


function testProtectQuotes(This)

expTxt = file2char('testFragile.txt');
expRemoved = file2char('testFragile_removedQuotes.txt');

f = fragileobj(expTxt);
[c,f] = protectquotes(expTxt,f);
actRemoved = cleanup(c,f);
actTxt = restore(c,f);

assertEqual(This,actTxt,expTxt);
assertEqual(This,actRemoved,expRemoved);

end % testProtectQuotes()


%**************************************************************************


function testProtectAll(This)

expTxt = file2char('testFragile.txt');

f1 = fragileobj(expTxt);
[c1,f1] = protectbraces(expTxt,f1);

f2 = fragileobj(c1);
[c2,f2] = protectbrackets(c1,f2);

f3 = fragileobj(c2);
[c3,f3] = protectquotes(c2,f3);

c2 = restore(c3,f3);
c1 = restore(c2,f2);
actTxt = restore(c1,f1);

assertEqual(This,actTxt,expTxt);

end % testProtectBrackets()