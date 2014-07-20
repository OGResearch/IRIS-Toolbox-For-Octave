function actString = testDregexprep(C)
x = zeros(1,10);
x(1) = 56;
x(2) = -600;
x(5) = pi;
x(10) = 1e15;

actString = mosw.dregexprep(C,'([#&])(\d+)','doReplace',[1,0,2]);

    function C = doReplace(C1,C0,C2)
        k = sscanf(C2,'%g');
        m = '';
        if C1 == '#'
            m = 'A';
        elseif C1 == '&'
            m = 'B';
        end    
        C = [C0,'=',m,sprintf('%g',x(k))];
    end 


end % testDregexprep()