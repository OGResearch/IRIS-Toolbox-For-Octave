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


%**************************************************************************

function testClone(This)

c = ...
    '!variables A, Bb, Ccc !equations A=0; Bb=0; Ccc=0;';
expCode = ...
    '!variables US_A, US_Bb, US_Ccc !equations US_A=0; US_Bb=0; US_Ccc=0;';

actCode = preparser.myclone(c,'US_?');
assertEqual(This,actCode,expCode);

end % testClone()


%**************************************************************************


function testPseudosubs(This)

p = preparser('testPseudosubs.model');
actCode = p.code;
expCode = file2char('testPseudosubs_preparsed.model');
assertEqual(This,actCode,expCode);

end % testPseudosubs()
