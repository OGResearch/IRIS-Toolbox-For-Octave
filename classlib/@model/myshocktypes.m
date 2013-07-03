function [MShocks,TShocks] = myshocktypes(This)
% xxshocktypes  [Not a public function] Indices of measurement and transition shocks.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

t = This.tzero;
nName = length(This.name);
inx = nName*(t-1) + find(This.nametype == 3);
mOccur = This.occur(This.eqtntype == 1,inx);
tOccur = This.occur(This.eqtntype == 2,inx);

MShocks = any(mOccur,1);
TShocks = any(tOccur,1);

end