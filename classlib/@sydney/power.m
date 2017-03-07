function This = power(A,B)
% times  [Not a public function] Overloaded power and mpower for sydney class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

persistent SYDNEY;

if isnumeric(SYDNEY)
    SYDNEY = sydney();
end

%--------------------------------------------------------------------------

This = SYDNEY;
This.args = cell(1,2);
This.func = 'power';
This.lookahead = false(1,2);

if isnumeric(A)
    x = A;
    A = SYDNEY;
    A.args = x;
    This.lookahead(1) = false;
else
    This.lookahead(1) = any(A.lookahead);
end

if isnumeric(B)
    x = B;
    B = SYDNEY;
    B.args = x;
    This.lookahead(2)= false;
else
    This.lookahead(2) = any(B.lookahead);
end

This.args = {A,B};

end