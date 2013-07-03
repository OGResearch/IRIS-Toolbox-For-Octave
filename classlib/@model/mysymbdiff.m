function This = mysymbdiff(This)
% mysymbdiff  [Not a public function] Evaluate symbolic derivatives for model equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Symbolic derivatives of
% * full measurement and transition equations wrt variables;
% * full dtrend equations wrt parameters.
% No derivatives computed for dynamic links.
nEqtn = length(This.eqtn);
This.deqtnF = cell(1,nEqtn);
This.ceqtnF = cell(1,nEqtn);
tZero = This.tzero;

for ieq = find(This.eqtntype <= 3)
    
    if This.eqtntype(ieq) <= 2
        % Measurement or transition equations; differentiate equations w.r.t.
        % variables and shocks.
        [tmOcc,nmOcc] = myfindoccur(This,ieq,'variables_shocks');
        tmOcc = tmOcc - tZero;
        mode = 1;
    elseif This.eqtntype(ieq) == 3
        % Deterministic trends; differentiate dtrends w.r.t. parameters.
        [tmOcc,nmOcc] = myfindoccur(This,ieq,'parameters');
        tmOcc(:) = 0;
        mode = Inf;
    end
    
    % Differentiate one equation wrt all names at a time. The result will be
    % one multivariate derivative (`mode`==1) or several separate derivatives
    % (`mode`==Inf).
    eqtn = This.eqtnF{ieq};
    dEqtn = sydney.mydiffeqtn(eqtn,mode,nmOcc,tmOcc,This.log);
    
    % Store strings; the strings are coverted to anonymous functions later.
    This.deqtnF{ieq} = dEqtn;
    
    % Create function for evaluating the constant term in each equation in
    % linear models. Do this also in non-linear models because `solve` can be
    % now called with `'linear=' true`.
    if This.eqtntype(ieq) <= 2
        cEqtn = myconsteqtn(This,This.eqtnF{ieq});
        This.ceqtnF{ieq} = cEqtn;
    end
    
end

end