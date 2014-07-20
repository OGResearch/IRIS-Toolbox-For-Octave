function EqtnS = myfinaleqtns(This,IsGrowth)
% myfinaleqtns  [Not a public function] Finalize lags and leads in sstate equations for evaluation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

ixEmpty = cellfun(@isempty,This.EqtnS);
EqtnS = This.EqtnS;
if all(ixEmpty)
    return
end

% Non-empty sstate equations only.
eqtn = This.EqtnS(~ixEmpty);

if IsGrowth
    % Equations with growth
    %-----------------------
    % How leads and lags are expanded depends on the current log status of
    % each variable. The log status can change within the model object
    % during its lifecycle.
    
    % Lags and leads are guaranteed to have an explicit plus sign at this
    % point.
    
    % Cycle over log variables.
    for i = find(This.IxLog & This.nametype <= 2)
        c = sprintf('%g',i);
        % Leads of log variables.
        % Replace `x(10){+2}` with `(x(10)*dx(10)^2)`.
        eqtn = regexprep(eqtn, ...
        ['x\(',c,'\)\{\+(\d+)\}'], ...
        ['(x(',c,')*dx(',c,')^$1)']);
        % Lags of log variables.
        % Replace `x(10){-2}` with `(x(10)/dx(10)^2)`.
        eqtn = regexprep(eqtn, ...
        ['x\(',c,'\)\{\-(\d+)\}'], ...
        ['(x(',c,')/dx(',c,')^$1)']);
    end
    
    % Cycle over non-log variables.
    for i = find(~This.IxLog & This.nametype <= 2)
        c = sprintf('%g',i);
        % Lags and leads of non-log variables.
        % Replace `x(10){-2}` with `(x(10)-2*dx(10))`.
        eqtn = regexprep(eqtn, ...
        ['x\(',c,'\)\{([\+\-]\d+)\}'], ...
        ['(x(',c,')$1*dx(',c,'))']);        
    end
else
    % Equations with no growth
    %--------------------------
    % Replace
    % * `x(10){-2}` with `x(10)`.
    eqtn = regexprep(eqtn, ...
        '(x\(\d+\))\{([\+\-]\d+)\}', ...
        '$1');
end

EqtnS(~ixEmpty) = eqtn;

end
