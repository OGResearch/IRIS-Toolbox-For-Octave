function [Z,C] = lincomb2vec(S,List)
% lincomb2vec  [Not a public function] Convert a string with a linear combination of variables to a coefficient vector.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ~iscell(S)
    S = {S};
end
S = S(:).';

ns = length(S);
nList = length(List);

List = regexptranslate('escape',List);
for i = 1 : nList
    S = regexprep(S,['\<',List{i},'\>'],sprintf('x(%g)',i));
end

Z = zeros(ns,nList);
C = zeros(ns,1);
for i = 1 : ns
    [Z(i,:),C(i)] = xxLinComb2Vec(S{i},nList);
end

end

% Subfunctions.

%**************************************************************************
function [Z,C] = xxLinComb2Vec(S,nlist)

f = str2func(['@(x)',S]);
x = zeros(1,nlist);
try
    C = f(x);
catch %#ok<CTCH>
    C = NaN;
end
Z = nan(1,nlist);

for i = 1 : nlist
    x = zeros(1,nlist);
    x(i) = 1;
    Z(i) = f(x) - C;
end

end % xxLinComb2Vec().