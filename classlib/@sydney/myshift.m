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

replaceFn = @doReplace; %#ok<NASGU>
if ismatlab
    Eqtn = regexprep(Eqtn,'\<x(\d+)([pm]\d+)?\>(?!\()','x${replaceFn($1,$2)}');
else
    Eqtn = myregexprep(Eqtn,'\<x(\d+)([pm]\d+)?\>(?!\()','x${doReplace($1,$2)}');
end

    function C = doReplace(C1,C2)
        n = sscanf(C1,'%g',1);
        if ~ApplyTo(n)
            C = [C1,C2];
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
        C = [C1,C2];
    end


end