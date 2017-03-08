expTxt = file2char('testFragile.txt');
expRemoved = file2char('testFragile_removedQuotes.txt');

f = fragileobj(expTxt);
[c,f] = protectquotes(expTxt,f);
actRemoved = cleanup(c,f);
actTxt = restore(c,f);

myassert(actTxt,expTxt);
myassert(actRemoved,expRemoved);