function [ActValue1,ActValue2,ExpValue] = xxEval(Eqtn,Wrt,ExpFunc)

N = 1;
wrtList = fieldnames(Wrt);
nWrt = length(wrtList);
wrtCharList = sprintf('%s,',wrtList{:});
wrtCharList(end) = '';
z = sydney(Eqtn,wrtList);

% En-bloc derivatives.
dz1 = diff(z,'enbloc',wrtList);
dz1 = char(dz1);
actFunc1 = mosw.str2func(['@(',wrtCharList,') ',char(dz1)]);

% Separate derivatives.
dz2 = diff(z,'separate',wrtList);
for i = 1 : nWrt
    dz2{i} = char(dz2{i});
end
actFunc2 = mosw.str2func(['@(',wrtCharList,') [',sprintf('%s;',dz2{:}),']']);

ActValue1 = nan(nWrt,N);
ActValue2 = nan(nWrt,N);
ExpValue = nan(nWrt,N);

for i = 1 : N
    while true
        % Make sure the random values don't produce NaNs or Infs when evaluated on
        % the true function.
        wrtArg = cell(1,nWrt);
        for j = 1 : nWrt
            name = wrtList{j};
            if isnumeric(Wrt.(name))
                wrtArg{j} = Wrt.(name);
            else
                wrtArg{j} = Wrt.(name)();
            end
        end
        ExpValue(:,i) = ExpFunc(wrtArg{:});
        if all(isfinite(ExpValue(:,i)))
            break
        end
    end
    ActValue1(:,i) = actFunc1(wrtArg{:});
    ActValue2(:,i) = actFunc2(wrtArg{:});
end

end % xxEval()