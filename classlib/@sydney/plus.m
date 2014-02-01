function This = plus(A,B)
% plus  [Not a public function] Overloaded plus for sydney class.
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
This.func = 'plus';

isZeroA = isequal(A,0) || (~isnumeric(A) && isequal(A.args,0));
isZeroB = isequal(B,0) || (~isnumeric(B) && isequal(B.args,0));
if isZeroA || isZeroB
    if isZeroA && isZeroB
        This = SYDNEY;
        This.args = 0;
        This.lookahead = false;
        return
    elseif isZeroA
        if isnumeric(B)
            This = SYDNEY;
            This.args = B;
            This.lookahead = false;
            return
        else
            This = B;
            return
        end
    else
        if isnumeric(A)
            This = SYDNEY;
            This.args = A;
            This.lookahead = false;
            return
        else
            This = A;
            return
        end
    end
end

isNumericB = isnumeric(B);
isPlusB = ~isNumericB && strcmp(B.func,'plus');

if isnumeric(A)
    x = A;
    A = SYDNEY;
    A.args = x;
    This.args = {A}; 
    This.lookahead = false;
elseif strcmp(A.func,'plus')
    if ~isNumericB && ~isPlusB
        This.args = [A.args,{B}];
        This.lookahead = [A.lookahead,any(B.lookahead)];
        return
    end  
    This.args = A.args;
    This.lookahead = A.lookahead;
else
    if ~isNumericB && ~isPlusB
        This.args = {A,B};
        This.lookahead = [any(A.lookahead),any(B.lookahead)];
        return
    end
    This.args = {A};
    This.lookahead = any(A.lookahead);
end

if isNumericB
    x = B;
    B = SYDNEY;
    B.args = x;
    This.args = [This.args,{B}]; 
    This.lookahead = [This.lookahead,false];
elseif isPlusB
    This.args = [This.args,B.args];
    This.lookahead = [This.lookahead,B.lookahead];
else
    This.args = [This.args,{B}];
    This.lookahead = [This.lookahead,any(B.lookahead)];
end

end