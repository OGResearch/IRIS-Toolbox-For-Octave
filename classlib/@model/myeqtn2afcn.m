function This = myeqtn2afcn(This)
% myeqtn2afcn  [Not a public function] Convert equation strings to anonymous functions.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

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
        e = str2func(['@(x,t,L) ',eqtnF{i}]);
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
        eqtnF{i} = str2func(['@(x,t,ttrend,g) ',eqtnF{i}]);
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
        eqtnF{i} = str2func(['@(x,t) ',eqtnF{i}]);
    end
end

This.eqtnF = eqtnF;

% Derivatives and constant terms
%--------------------------------

deqtnF = This.deqtnF;
ceqtnF = This.ceqtnF;

% Derivatives of transition and measurement equations wrt variables and
% shocks.
for i = find(This.eqtntype <= 2)
    deqtnF{i} = removeFunc(deqtnF{i});
    deqtnF{i} = str2func(['@(x,t,L) ',deqtnF{i}]);
    if ischar(ceqtnF{i})
        ceqtnF{i} = removeFunc(ceqtnF{i});
        ceqtnF{i} = str2func(['@(x,t,L) ',ceqtnF{i}]);
    end
end

% Derivatives of dtrend equations wrt parameters.
for i = find(This.eqtntype == 3)
    if isempty(deqtnF{i})
        continue
    end
    for j = 1 : length(deqtnF{i})
        deqtnF{i}{j} = removeFunc(deqtnF{i}{j});
        deqtnF{i}{j} = str2func(['@(x,t,ttrend,g) ',deqtnF{i}{j}]);
    end
end

This.deqtnF = deqtnF;
This.ceqtnF = ceqtnF;

% Non-linear equations
%----------------------
eqtnN = This.eqtnN;

% Non-linearised equations.
for i = 1 : length(eqtnN)
    if isempty(eqtnN{i})
        continue
    end
    eqtnN{i} = removeFunc(eqtnN{i});
    eqtnN{i} = str2func(['@(y,xx,e,p,t,L) ',eqtnN{i}]);
end

This.eqtnN = eqtnN;

end