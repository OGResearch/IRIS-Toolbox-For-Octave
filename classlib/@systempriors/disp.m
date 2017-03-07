function disp(This)
% disp  [Not a public function] Display method for systempriors objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(This)
    fprintf('\tempty systempriors object\n');
else
    fprintf('\tsystempriors object\n');
    fprintf('\t#priors imposed: %g\n',length(This));
end

disp@userdataobj(This);
disp(' ');

end
