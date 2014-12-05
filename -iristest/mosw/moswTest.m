function Tests = moswTest()
Tests = functiontests(localfunctions);
end
%#ok<*DEFNU>


%**************************************************************************


function testDregexprep(This)

C         = 'ABCDEF #1 &2 #10 abcdefgh 0 123 &5 456 789';
expString = 'ABCDEF A56 B-600 A1e+15 abcdefgh 0 123 B3.14159 456 789';
x = zeros(1,10);
x(1) = 56;
x(2) = -600;
x(5) = pi;
x(10) = 1e15;

replaceFunc = @doReplace; %#ok<NASGU>
actString1 = regexprep(C,'([#&])(\d+)','${replaceFunc($1,$2)}');
actString2 = mosw.dregexprep(C,'([#&])(\d+)',@doReplace,[1,2]);

assertEqual(This,actString1,expString);
assertEqual(This,actString2,expString);


    function C = doReplace(C1,C2)
        k = sscanf(C2,'%g');
        m = '';
        if C1 == '#'
            m = 'A';
        elseif C1 == '&'
            m = 'B';
        end    
        C = [m,sprintf('%g',x(k))];
    end 


end % testDregexprep()