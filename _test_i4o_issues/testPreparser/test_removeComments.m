c = file2char('testRemoveComments.txt');
expText = file2char('testRemoveComments_removed.txt');

f = fragileobj(c);
[c,f] = protectquotes(c,f);
c = cleanup(c,f);

actText = preparser.removecomments(c);
myassert(actText,expText);