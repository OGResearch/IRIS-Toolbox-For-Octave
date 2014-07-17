function Eqtn = myshift(Eqtn,Shift,ApplyTo)
% myshift  [Not a public function] Shift all lags and leads of variables.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if Shift == 0
    return
end

ptn = '\<x(\d+)(([pm]\d+)?)\>(?!\()';
if true % ##### MOSW
    replaceFn = @doReplace; %#ok<NASGU>
    Eqtn = regexprep(Eqtn,ptn,'${replaceFn($0,$1,$2)}');
else
    Eqtn = mosw.dregexprep(Eqtn,ptn,@doReplace,[0,1,2]); %#ok<UNRCH>
end


    function C = doReplace(C0,C1,C2)
        n = sscanf(C1,'%g',1);
        if ~ApplyTo(n)
            C = C0;
            return
        end
        if isempty(C2)
            oldSh = 0;
        elseif C2(1) == 'p'
            oldSh = sscanf(C2(2:end),'%g',1);
        elseif C2(1) == 'm'
            oldSh = -sscanf(C2(2:end),'%g',1);
        end
        newSh = round(oldSh + Shift);
        if newSh == 0
            C2 = '';
        elseif newSh > 0
            C2 = sprintf('p%g',newSh);
        else
            C2 = sprintf('m%g',-newSh);
        end
        C = ['x',C1,C2];
    end % doReplace()


end
