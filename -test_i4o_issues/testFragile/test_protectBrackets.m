expTxt = file2char('testFragile.txt');
expRemoved = file2char('testFragile_removedBrackets.txt');

f = fragileobj(expTxt);
[c,f] = protectbrackets(expTxt,f);
actRemoved = cleanup(c,f);
actTxt = restore(c,f);

myassert(actTxt,expTxt);
myassert(actRemoved,expRemoved);