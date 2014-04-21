function disp(This)
% disp  [Not a public function] Display method for model objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(This.Assign)
    fprintf('\tempty model object\n');
    doPrintNEqtn();
else
    nAlt = size(This.Assign,3);
    fprintf('\t');
    if This.linear
        fprintf('linear ');
    else
        fprintf('nonlinear ');
    end
    fprintf('model object: [%g] parameterisation(s)\n',nAlt);
    doPrintNEqtn();
    doPrintSolution();
end

disp@userdataobj(This);
disp(' ');


% Nested functions...


%**************************************************************************
    function doPrintNEqtn()
        nm = sum(This.eqtntype == 1);
        nt = sum(This.eqtntype == 2);
        fprintf('\tnumber of equations: [%g %g]\n',nm,nt);
    end % doPrintNEqtn()


%**************************************************************************
    function doPrintSolution()
        [~,inx] = isnan(This,'solution');
        nSolution = sum(~inx);
        fprintf('\tsolution(s) available: [%g] parameterisation(s)\n', ...
            nSolution);
    end % doPrintSolution()


end