C         = 'ABCDEF #1 &2 #10 abcdefgh 0 123 &5 456 789';
expString = 'ABCDEF #1=A56 &2=B-600 #10=A1e+15 abcdefgh 0 123 &5=B3.14159 456 789';
if ispc
  expString = strrep(expString,'e+15','e+015');
end

actString = testDregexprep(C);

myassert(actString,expString)