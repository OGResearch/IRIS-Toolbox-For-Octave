function disp(This)
% disp  [Not a public function] Display method for model objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

thisClass = class(This);
nAlt = size(This.Assign,3);

if This.linear
    thisLinear = 'linear';
else
    thisLinear = 'non-linear';
end

if isempty(This.Assign)
    fprintf('\tempty %s object\n',thisClass);
    doPrintNEqtn();
else
    [~,inx] = isnan(This,'solution');
    fprintf('\t%s %s object: [%g] parameterisation(s)\n', ...
        thisLinear,thisClass,nAlt);
    doPrintNEqtn();
    doPrintSolution();
end

disp@userdataobj(This);
disp(' ');

% Nested functions.

%**************************************************************************
    function doPrintNEqtn()
        nm = sum(This.eqtntype == 1);
        nt = sum(This.eqtntype == 2);
        fprintf('\tnumber of equations: [%g %g]\n',nm,nt);
    end % doPrintNEqtn().

%**************************************************************************
    function doPrintSolution()
        nSolution = sum(~inx);
        fprintf('\tsolution(s) available: [%g] parameterisation(s)\n', ...
            nSolution);
    end % doPrintSolution().

end