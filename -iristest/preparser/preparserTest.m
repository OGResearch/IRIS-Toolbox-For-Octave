function Tests = preparserTest()
Tests = functiontests(localfunctions);
end
%#ok<*DEFNU>


%**************************************************************************


function testRemoveComments(This)

c = file2char('testRemoveComments.txt');
expText = file2char('testRemoveComments_removed.txt');

f = fragileobj(c);
[c,f] = protectquotes(c,f);
c = cleanup(c,f);

actText = preparser.removecomments(c);
assertEqual(This,actText,expText);

end % testRemoveComments()