function This = myoccurrence(This,EqtnList)
% myoccurrence  [Not a public function] Find and record the occurences of
% individual variables, parameters, and shocks in equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isequal(EqtnList,Inf)
    EqtnList = 1 : length(This.eqtn);
end

tZero = This.tzero;
nEqtn = length(This.eqtn);
nName = length(This.name);
nt = size(This.occur,2)/nName;
offsetG = sum(This.nametype < 5);

% Steady-state equations
%------------------------

if ~This.linear
    nameCurr = cell(size(This.eqtn));
    
    % Look for x(10).
    nameCurr(EqtnList) = ...
        regexp(This.EqtnS(EqtnList),'\<x\((\d+)\)','tokens');
    
    % Loog for g(10).
    nameExog(EqtnList) = ...
        regexp(This.EqtnS(EqtnList),'\<g\((\d+)\)','tokens');
    
    for iEq = EqtnList
        if isempty(This.EqtnS{iEq}) ...
                || (isempty(nameCurr{iEq}) && isempty(nameExog{iEq}))
            continue
        end
        
        iNameCurr = [nameCurr{iEq}{:}];
        if ~isempty(iNameCurr)
        nameSub = sprintf('%s,',iNameCurr{:});
        nameSub = sscanf(nameSub,'%g,');
        ind = sub2ind([nEqtn,nName],iEq*ones(size(nameSub)),nameSub);
        This.occurS(ind) = true;
        end
        
        iNameExog = [nameExog{iEq}{:}];
        if ~isempty(iNameExog)
            nameSub = sprintf('%s,',iNameExog{:});
            nameSub = sscanf(nameSub,'%g,');
            nameSub = nameSub + offsetG;
            ind = sub2ind([nEqtn,nName],iEq*ones(size(nameSub)),nameSub);
            This.occurS(ind) = true;
        end
    end
end

% Full equations
%----------------

nameTime = cell(size(This.eqtn));
nameCurr = cell(size(This.eqtn));
nameExog = cell(size(This.eqtn));

% Look for x(:,10,t+2) and x(10,t).
nameTime(EqtnList) = ...
    regexp(This.eqtnF(EqtnList),'\<x\(:,(\d+),t([+\-]\d+)\)','tokens');
nameCurr(EqtnList) = ...
    regexp(This.eqtnF(EqtnList),'\<x\(:,(\d+),t\)','tokens');
nameExog(EqtnList) = ...
    regexp(This.eqtnF(EqtnList),'\<g\((\d+),:\)','tokens');

for iEq = EqtnList
    if isempty(This.eqtnF{iEq})
        continue
    end

    iNameTime = [nameTime{iEq}{:}];
    if ~isempty(iNameTime)
        sub = sprintf('%s,',iNameTime{:});
        sub = sscanf(sub,'%g,');
        nameSub = sub(1:2:end);
        timeSub = tZero + sub(2:2:end);
        ind = sub2ind([nEqtn,nName,nt], ...
            iEq*ones(size(nameSub)),nameSub,timeSub);
        This.occur(ind) = true;
    end
    
    iNameCurr = [nameCurr{iEq}{:}];
    if ~isempty(iNameCurr)
        nameSub = sprintf('%s,',iNameCurr{:});
        nameSub = sscanf(nameSub,'%g,');
        timeSub = tZero*ones(size(nameSub));
        ind = sub2ind([nEqtn,nName,nt], ...
            iEq*ones(size(nameSub)),nameSub,timeSub);
        This.occur(ind) = true;
    end
    
    iNameExog = [nameExog{iEq}{:}];
    if ~isempty(iNameExog)
        nameSub = sprintf('%s,',iNameExog{:});
        nameSub = sscanf(nameSub,'%g,');
        nameSub = nameSub + offsetG;
        timeSub = tZero*ones(size(nameSub));
        ind = sub2ind([nEqtn,nName,nt], ...
            iEq*ones(size(nameSub)),nameSub,timeSub);
        This.occur(ind) = true;
    end

end

end