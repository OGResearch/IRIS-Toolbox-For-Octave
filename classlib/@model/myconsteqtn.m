function Eqtn = myconsteqtn(This,Eqtn)
% myconsteqtn  [Not a public function] Create an equation for evaluating constant terms in linear models.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Replace
% * all non-log variables with 0;
% * all log variables with 1.
replaceFunc = @doReplace; %#ok<NASGU>
Eqtn = regexprep(Eqtn,'x\(:,(\d+),t[^\)]*\)', ...
   '${replaceFunc($0,$1)}');

Eqtn = sydney.myeqtn2symb(Eqtn);
Eqtn = sydney(Eqtn,{});
Eqtn = reduce(Eqtn);
Eqtn = char(Eqtn);
Eqtn = sydney.mysymb2eqtn(Eqtn);

x = sscanf(Eqtn,'%g');
if isnumericscalar(x) && isfinite(x)
    Eqtn = x;
end


    function c = doReplace(c0,c1)
        c = sscanf(c1,'%g');
        if This.nametype(c) <= 3
            if This.log(c)
                c = '1';
            else
                c = '0';
            end
        else
            c = c0;
        end
    end % doReplace()


end