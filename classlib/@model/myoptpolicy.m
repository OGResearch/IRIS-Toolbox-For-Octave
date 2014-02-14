function [NewEqtn,NewEqtnF,NewEqtnS,NewNonlin] ...
    = myoptpolicy(This,LossPos,LossDisc)
% myoptpolicy  [Not a public function] Calculate equations for discretionary optimal policy.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

template = sydney();

% Make the model names visible inside dynamic regexps.
name = This.name; %#ok<NASGU>

eqtn = cell(size(This.eqtnF));
eqtn(:) = {''};
eqtn(This.nametype == 2) = This.eqtnF(This.nametype == 2);

% Replace x(:,n,t+k) with xN, xNpK, or xNmK, and &x(n) with Ln.
eqtn = sydney.myeqtn2symb(eqtn);
LossDisc = sydney.myeqtn2symb(LossDisc);

% First transition equation.
first = find(This.eqtntype == 2,1);

% The loss function is always the last equation. After the loss function,
% there are empty place holders. The new equations will be put in place of
% the loss function and the placeholders.
NewEqtn = cell(size(eqtn));
NewEqtn(:) = {''};
NewEqtnF = NewEqtn;
NewEqtnS = NewEqtn;
NewNonlin = false(size(eqtn));
logList = find(This.log);
zd = sydney(LossDisc,{});

% The lagrangian is
%
%     Mu_Eq1*eqtn1 + Mu_Eq2*eqtn2 + ... + lossfunc.
%
% The new k-th (k runs only for the original transition variables) equation
% is the derivative of the lagrangian wrt to the k-th variable, and is
% given by
%
%     Mu_Eq1*diff(eqtn1,namek) + Mu_Eq2*diff(eqtn2,namek) + ...
%     + diff(lossfunc,namek) = 0.
%
% We loop over the equations, and build gradually the new equations from
% the individual derivatives.

for eq = first : LossPos
    
    % Get the list of all variables and shocks (current dates, lags, leads) in
    % this equation.
    [tmOcc,nmOcc] = myfindoccur(This,eq,'variables_shocks');
    tmOcc = tmOcc(:).';
    nmOcc = nmOcc(:).';
    
    % This is a discretionary policy. We only differentiate wrt to current
    % dates or lags of transition variables. Remove leads from the list of
    % variables wrt which we will differentiate.
    inx = This.nametype(nmOcc) == 2 & tmOcc <= This.tzero;
    tmOcc = tmOcc(inx);
    nmOcc = nmOcc(inx);
    nOcc = length(tmOcc);
    
    % Write a cellstr with the symbolic names of variables wrt which we will
    % differentiate.
    unknown = cell(1,nOcc);
    for j = 1 : nOcc
        if tmOcc(j) == This.tzero
            % Time index == 0: replace x(1,23,t) with x23.
            unknown{j} = sprintf('x%g',nmOcc(j));
        else
            % Time index < 0: replace x(1,23,t-1) with x23m1.
            unknown{j} = sprintf('x%gm%g', ...
                nmOcc(j),round(This.tzero-tmOcc(j)));
        end
    end
    
    z = sydney(eqtn{eq},unknown);
    
    % Differentiate this equation wrt to all variables and return a cell array
    % of separate sydney objects for each derivative.
    diffz = diff(z,'separate',unknown);
  
    for j = 1 : nOcc

        shift = -(tmOcc(j) - This.tzero);
        newEq = nmOcc(j);
        
        % Multiply derivatives wrt lagged variables by the discount factor.
        if shift == 1
            diffz{j} = zd * diffz{j};
        elseif shift > 1
            diffz{j} = power(zd,shift) * diffz{j};
        end
        
        % If this is not the loss function, multiply the derivative by
        % the multiplier.
        if eq < LossPos
            if shift == 0
                x = template;
                x.args = sprintf('x%g',eq);
                diffz{j} = diffz{j}*x;
            elseif shift == 1
                x = template;
                x.args = sprintf('x%gp1',eq);
                diffz{j} = diffz{j}*x;
            else
                x = template;
                x.args = sprintf('x%gp%g',eq,shift);
                diffz{j} = diffz{j}*x;
            end
        end

        dEqtn = char(reduce(diffz{j}),'human');
        
        dEqtnF = sydney.mysymb2eqtn(dEqtn);
        if ~This.linear
            dEqtnS = sydney.mysymb2eqtn(dEqtn,'sstate',logList); %#ok<FNDSB>
        end
 
        dEqtn = regexprep(dEqtn,'x(\d+)p(\d+)', ...
            '${[name{sscanf($1,''%g'')},''{+'',$2,''}'']}');
        dEqtn = regexprep(dEqtn,'x(\d+)m(\d+)', ...
            '${[name{sscanf($1,''%g'')},''{-'',$2,''}'']}');
        dEqtn = regexprep(dEqtn,'x(\d+)', ...
            '${name{sscanf($1,''%g'')}}');
        dEqtn = regexprep(dEqtn, ...
            'L(:,\d+)','${[''&'',name{sscanf($1,''%g'')}]}');
        
        % Put together the derivative of the Lagrangian wrt to variable
        % #neweq.
        if isempty(NewEqtn{newEq})
            NewEqtn{newEq} = '=0;';
            NewEqtnF{newEq} = ';';
            if ~This.linear
                NewEqtnS{newEq} = ';';
            end
        end
        
        sign = '+';
        if strncmp(NewEqtn{newEq},'-',1) ...
                || strncmp(NewEqtn{newEq},'+',1) ...
                || strncmp(NewEqtn{newEq},'=',1)
            sign = '';
        end
        NewEqtn{newEq} = [dEqtn,sign,NewEqtn{newEq}];
        NewEqtnF{newEq} = [dEqtnF,sign,NewEqtnF{newEq}];
        if ~This.linear
            NewEqtnS{newEq} = [dEqtnS,sign,NewEqtnS{newEq}];
            % Earmark the derivative for non-linear simulation if at least one equation
            % in it is non-linear and the derivative is non-zero. The derivative of the
            % loss function is supposed to be treated as non-linear if the loss
            % function itself has been introduced by min#() and not min().
            isNonlin = This.nonlin(eq) && ~isequal(dEqtn,'0');
            NewNonlin(newEq) = NewNonlin(newEq) || isNonlin;
        end
        
    end
end

if ~This.linear
    % Replace = with #= in non-linear human equations.
    NewEqtn(NewNonlin) = strrep(NewEqtn(NewNonlin),'=0;','=#0;');
end

end