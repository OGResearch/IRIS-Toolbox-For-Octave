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
else
    [~,inx] = isnan(This,'solution');
    fprintf('\t%s %s object: %g parameterisation(s)\n', ...
        thisLinear,thisClass,nAlt);
    nSolution = sum(~inx);
    if nSolution == 0
        howmany = 'no parameterisation';
    else
        howmany = sprintf('a total of %g parameterisation(s)',nSolution);
    end
    fprintf('\tsolution(s) available for %s\n',howmany);
end

disp@userdataobj(This);
disp(' ');

end