function disp(This)
% disp  [Not a public function] Display method for likfunc objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

listFunc = @(x) sprintf('''%s'' ',x{:});

if isempty(This.userFunc)
    fprintf('\tempty likfunc object\n');
else
    fprintf('\t');
    if ~isempty(This.form)
        fprintf('%s ',This.form);
    end
    fprintf('likfunc object: %s\n',This.userFunc);
    fprintf('\tdata names: %s\n',listFunc(This.name(This.nameType == 1)));
    fprintf('\tparameter names: %s\n',listFunc(This.name(This.nameType == 2)));
end

disp@userdataobj(This);
disp(' ');

end