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
        eqtnF{i} = mosw.str2func(['@(x,t,L) ',eqtnF{i}]);
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
        eqtnF{i} = mosw.str2func(['@(x,t,ttrend,g) ',eqtnF{i}]);
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
        eqtnF{i} = mosw.str2func(['@(x,t) ',eqtnF{i}]);
    end
end

This.eqtnF = eqtnF;

% Derivatives and constant terms
%--------------------------------

dEqtnF = This.DEqtnF;
cEqtnF = This.CEqtnF;

% Non-empty derivatives.
isDEqtnF = ~cellfun(@isempty,This.DEqtnF);

% Derivatives of transition and measurement equations wrt variables and
% shocks.
inx = This.eqtntype <= 2 & isDEqtnF;
for i = find(inx)
    dEqtnF{i} = removeFunc(dEqtnF{i});
    dEqtnF{i} = mosw.str2func(['@(x,t,L) ',dEqtnF{i}]);
    if ischar(cEqtnF{i})
        cEqtnF{i} = removeFunc(cEqtnF{i});
        cEqtnF{i} = mosw.str2func(['@(x,t,L) ',cEqtnF{i}]);
    end
end

% Derivatives of dtrend equations wrt parameters.
inx = This.eqtntype == 3 & isDEqtnF;
for i = find(inx)
    if isempty(dEqtnF{i})
        continue
    end
    for j = 1 : length(dEqtnF{i})
        dEqtnF{i}{j} = removeFunc(dEqtnF{i}{j});
        dEqtnF{i}{j} = mosw.str2func(['@(x,t,ttrend,g) ',dEqtnF{i}{j}]);
    end
end

This.DEqtnF = dEqtnF;
This.CEqtnF = cEqtnF;

end
