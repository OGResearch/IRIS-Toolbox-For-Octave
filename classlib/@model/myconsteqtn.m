function Eqtn = myconsteqtn(This,Eqtn)
% myconsteqtn  [Not a public function] Create an equation for evaluating constant terms in linear models.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Replace
% * all non-log variables with 0;
% * all log-plus and log-minus variables with 1.

ptn = '\<x\(:,(\d+),t[^\)]*\)';
if false % ##### MOSW
    replaceFunc = @doReplace; %#ok<NASGU>
    Eqtn = regexprep(Eqtn,ptn,'${replaceFunc($0,$1)}');
else
    Eqtn = mosw.dregexprep(Eqtn,ptn,'doReplace',[0,1]); %#ok<UNRCH>
end

Eqtn = sydney.myeqtn2symb(Eqtn);
Eqtn = sydney(Eqtn,{});
Eqtn = reduce(Eqtn);
Eqtn = char(Eqtn);
Eqtn = sydney.mysymb2eqtn(Eqtn);
Eqtn = strtrim(Eqtn);

% If the constant is a plain number, store it as a numeric; we need to
% make sure that the entire string has been used up, otherwise an
% expression like 4*x(...) will be incorrectly stored as 4.
[x,count] = sscanf(Eqtn,'%g');
if count == length(Eqtn) && isnumericscalar(x) && isfinite(x)
    Eqtn = x;
end


    function c = doReplace(c0,c1)
        c = sscanf(c1,'%g');
        if This.nametype(c) <= 3
            if This.IxLog(c)
                c = '1';
            else
                c = '0';
            end
        else
            c = c0;
        end
    end % doReplace()


end