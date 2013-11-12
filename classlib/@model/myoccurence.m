function This = myoccurence(This,EqtnList)
% myocurence  [Not a public function] Find and record the occurences of
% individual variables, parameters, and shocks in equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isequal(EqtnList,Inf)
    EqtnList = 1 : length(This.eqtn);
end

tZero = This.tzero;
nEqtn = length(This.eqtn);
nName = length(This.name);
nt = size(This.occur,2)/nName;

% Steady-state equations
%------------------------

if ~This.linear
    nameCurr = cell(size(This.eqtn));
    
    % Look for x(10).
    nameCurr(EqtnList) = ...
        regexp(This.eqtnS(EqtnList),'x\((\d+)\)','tokens');
    
    for iEq = EqtnList
        if isempty(This.eqtnS{iEq}) || isempty(nameCurr{iEq})
            continue
        end
        iNameCurr = [nameCurr{iEq}{:}];
        nameSub = sprintf('%s,',iNameCurr{:});
        nameSub = sscanf(nameSub,'%g,');
        ind = sub2ind([nEqtn,nName],iEq*ones(size(nameSub)),nameSub);
        This.occurS(ind) = true;
    end
end

% Full equations
%----------------

nameTime = cell(size(This.eqtn));
nameCurr = cell(size(This.eqtn));

% Look for x(:,10,t+2) and x(10,t).
nameTime(EqtnList) = ...
    regexp(This.eqtnF(EqtnList),'x\(:,(\d+),t([+\-]\d+)\)','tokens');
nameCurr(EqtnList) = ...
    regexp(This.eqtnF(EqtnList),'x\(:,(\d+),t\)','tokens');

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
        ind = sub2ind([nEqtn,nName,nt], ...
            iEq*ones(size(nameSub)),nameSub,tZero*ones(size(nameSub)));
        This.occur(ind) = true;
    end
end

end