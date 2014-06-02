function disp(This)
% disp  [Not a public function] Display method for VAR objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

if isempty(This.A)
    fprintf('\tempty %s object',class(This));
else
    fprintf('\t');
    if ispanel(This)
        fprintf('Panel ');
    end
    fprintf('%s(%g) object: ',class(This),p);
    fprintf('[%g] parameterisation(s)',nAlt);
end
fprintf('\n');

fprintf('\tvariables: ');
if ~isempty(This.YNames)
    fprintf('[%g] %s',length(This.YNames),strfun.displist(This.YNames));
else
    fprintf('none');
end
fprintf('\n');

specdisp(This);

disp@userdataobj(This);
disp(' ');

end