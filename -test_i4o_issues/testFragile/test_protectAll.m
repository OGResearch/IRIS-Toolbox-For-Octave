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

myassert(actTxt,expTxt);