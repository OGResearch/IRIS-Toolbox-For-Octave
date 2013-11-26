function S = antunantfunc(S,Anticipate)
% antunantfunc  [Not a public function] Functions to handle anticipated and
% unanticipated values.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if isempty(S)
    S = struct();
end

%--------------------------------------------------------------------------

if Anticipate
    S.antFunc = @real;
    S.unantFunc = @imag;
    S.auFunc = @(ant,unant) complex(ant,unant);
else
    S.antFunc = @imag;
    S.unantFunc = @real;
    S.auFunc = @(ant,unant) complex(unant,ant);
end

end