function C = shortclass(This)
% shortclass  [Not a public function] Short class name of report objects.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

C = class(This);
C = strrep(C,'report.','');
C = strrep(C,'obj','');

end