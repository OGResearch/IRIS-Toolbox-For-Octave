function This = times(A,B)
% times  [Not a public function] Overloaded times and mtimes for sydney class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

persistent SYDNEY;

if isnumeric(SYDNEY)
    SYDNEY = sydney();
end

%--------------------------------------------------------------------------

This = SYDNEY;
This.args = cell(1,2);
This.func = 'times';
This.lookahead = false(1,2);

isZeroA = isequal(A,0) || (~isnumeric(A) && isequal(A.args,0));
isZeroB = isequal(B,0) || (~isnumeric(B) && isequal(B.args,0));
if isZeroA || isZeroB
    This = SYDNEY;
    This.args = 0;
    This.lookahead = false;
    return
end

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