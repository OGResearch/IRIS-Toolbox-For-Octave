function This = uminus(A)
% times  [Not a public function] Overloaded uminus for sydney class.
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

if strcmp(A.func,'uminus')
    This = A.args{1};
    return
end

This = SYDNEY;
This.func = 'uminus';
This.args = {A};
This.lookahead = any(A.lookahead);

end