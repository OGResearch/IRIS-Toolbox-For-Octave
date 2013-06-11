function [SolId,Name,Log,NameLabel,ContribEList,ContribYList] ...
    = hdatareq(This)
% hdatareq  [Not a public function] Object properties needed to initialise an hdata obj.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

SolId = This.solutionid;
Name = This.name;
Log = This.log;
NameLabel = This.namelabel;
ContribEList = This.name(This.nametype == 3);
ContribYList = This.name(This.nametype == 1);


end