function [SolId,Name,Log,NameLabel,ContribEList,ContribYList] ...
    = hdatareq(This)
% hdatareq  [Not a public function] Object properties needed to initialise an hdata obj.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(This.A,1);

SolId = cell(1,3);
SolId{1} = 1 : ny;
SolId{2} = zeros(1,0);
SolId{3} = ny + (1 : ny);

Name = [This.Ynames,This.Enames];
Log = false(size(Name));
NameLabel = Name;
ContribEList = This.Enames;
ContribYList = This.Ynames;

end