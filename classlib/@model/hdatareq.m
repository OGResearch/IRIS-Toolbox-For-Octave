function [SolId,Name,Log,NameLabel,ContEList,ContYList] = hdatareq(This)
% hdatareq  [Not a public function] Object properties needed to initialise an hdata obj.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

SolId = This.solutionid;
Name = This.name;
Log = This.log;

% Name labels; use the variable name if the label is empty.
NameLabel = This.namelabel;
ixEmpty = cellfun(@isempty,NameLabel);
NameLabel(ixEmpty) = Name(ixEmpty);

% Shock contributions list.
ContEList = [This.name(This.nametype == 3),{'Init+Const'}];

% Measurement contributions list.
ContYList = This.name(This.nametype == 1);

end