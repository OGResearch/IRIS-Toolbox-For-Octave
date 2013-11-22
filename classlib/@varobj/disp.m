function disp(This)
% disp  [Not a public function] Display method for VAR objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);
listFunc = @(x) sprintf('''%s'' ',x{:});

if isempty(This.A)
    fprintf('\tempty %s object',class(This));
else
    fprintf('\t');
    if ispanel(This)
        fprintf('Panel ');
    end
    fprintf('%s(%g) object: ',class(This),p);
    fprintf('[%g] parameterisation(s)',nAlt);
    if ispanel(This)
        nGrp = length(This.GroupNames);
        fprintf(' * %g group(s)',nGrp);
    end
end
fprintf('\n');

specdisp(This);

if ~isempty(This.Ynames)
    yNames = listFunc(This.Ynames);
else
    yNames = 'empty';
end
fprintf('\tvariable names: %s',yNames);
fprintf('\n');

% Group names for panel objects.
if ispanel(This)
    fprintf('\tgroup names: %s',listFunc(This.GroupNames));
    fprintf('\n');
end

disp@userdataobj(This);
disp(' ');

end