function This = myeqtn2afcn(This)
% myeqtn2afcn  [Not a public function] Convert equation strings to anonymous functions.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

removeFunc = @(x) regexprep(x,'@\(.*?\)','','once');

% Extract the converted equations into local variables to speed up the
% executiona considerably. This is a Matlab issue.

% Full dynamic equations
%------------------------

if ismatlab
    s2fH = @str2func;
else
    s2fH = @mystr2func;
end

eqtnF = This.eqtnF;

% Full measurement and transition equations.
for i = find(This.eqtntype <= 2)
    % Full model equations.
    if ~ischar(eqtnF{i})
        continue
    end
    if isempty(eqtnF{i})
        eqtnF{i} = @(x,t,L) 0;
    else
        eqtnF{i} = removeFunc(eqtnF{i});
        e = s2fH(['@(x,t,L) ',eqtnF{i}]);
        eqtnF{i} = e;
    end
end

% Dtrend equations.
for i = find(This.eqtntype == 3)
    % Full model equations.
    if ~ischar(eqtnF{i})
        continue
    end
    if isempty(eqtnF{i})
        eqtnF{i} = @(x,t,ttrend,g) 0;
    else
        eqtnF{i} = removeFunc(eqtnF{i});
        eqtnF{i} = s2fH(['@(x,t,ttrend,g) ',eqtnF{i}]);
    end
end

% Dynamic link equations.
for i = find(This.eqtntype == 4)
    if ~ischar(eqtnF{i})
        continue
    end
    if isempty(eqtnF{i})
        eqtnF{i} = [];
    else
        eqtnF{i} = removeFunc(eqtnF{i});
        eqtnF{i} = s2fH(['@(x,t) ',eqtnF{i}]);
    end
end

This.eqtnF = eqtnF;

% Derivatives and constant terms
%--------------------------------

deqtnF = This.deqtnF;
ceqtnF = This.ceqtnF;

% Non-empty derivatives.
isDeqtnF = ~cellfun(@isempty,This.deqtnF);

% Derivatives of transition and measurement equations wrt variables and
% shocks.
inx = This.eqtntype <= 2 & isDeqtnF;
for i = find(inx)
    deqtnF{i} = removeFunc(deqtnF{i});
    deqtnF{i} = s2fH(['@(x,t,L) ',deqtnF{i}]);
    if ischar(ceqtnF{i})
        ceqtnF{i} = removeFunc(ceqtnF{i});
        ceqtnF{i} = s2fH(['@(x,t,L) ',ceqtnF{i}]);
    end
end

% Derivatives of dtrend equations wrt parameters.
inx = This.eqtntype == 3 & isDeqtnF;
for i = find(inx)
    if isempty(deqtnF{i})
        continue
    end
    for j = 1 : length(deqtnF{i})
        deqtnF{i}{j} = removeFunc(deqtnF{i}{j});
        deqtnF{i}{j} = s2fH(['@(x,t,ttrend,g) ',deqtnF{i}{j}]);
    end
end

This.deqtnF = deqtnF;
This.ceqtnF = ceqtnF;

end