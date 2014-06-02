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
isPanel = ispanel(This);

if isempty(This.A)
    fprintf('\tempty %s object',class(This));
else
    fprintf('\t');
    if isPanel
        fprintf('Panel ');
    end
    fprintf('%s(%g) object: ',class(This),p);
    fprintf('[%g] parameterisation(s)',nAlt);
    if isPanel
        nGrp = length(This.GroupNames);
        fprintf(' * [%g] group(s)',nGrp);
    end
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

% Group names for panel objects.
fprintf('\tgroups: ');
if ~isPanel
    fprintf('implicit');
else
    fprintf('[%g] %s',length(This.GroupNames), ...
        strfun.displist(This.GroupNames));
end
fprintf('\n');

disp@userdataobj(This);
disp(' ');

end