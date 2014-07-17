function This = mydiff(This,Wrt)
% mydiff  [Not a public function] Differentiate a sydney expression.
%
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

persistent SYDNEY;
if isnumeric(SYDNEY)
    SYDNEY = sydney();
end

% @@@@@ MOSW
template = SYDNEY;

%--------------------------------------------------------------------------

nWrt = length(Wrt);

% This.lookahead = [];
zeroDiff = ~This.lookahead;

% `This` is a sydney object representing a variable name or a number; do
% what's needed and return immediately.
if isempty(This.func)
    
    if ischar(This.args)
        % `This` is a variable name.
        if nWrt == 1
            % If we differentiate wrt to a single variable, convert the derivative
            % directly to a number `0` or `1` instead of a logical index. This helps
            % reduce some expressions immediately.
            if strcmp(This.args,Wrt)
                This = template;
                This.args = 1;
            else
                This = template;
                This.args = 0;
            end
        else
            inx = strcmp(This.args,Wrt);
            if any(inx)
                This = template;
                vec = false(nWrt,1);
                vec(inx) = true;
                This.args = vec;
            else
                This = template;
                This.args = 0;
            end
        end
        
    elseif isnumeric(This.args)
        % `This` is a number.
        This = template;
        This.args = 0;
    else
        utils.error('sydney:mydiff','#Internal');
    end
    
    return

end

% None of the wrt variables occurs in the argument legs of this function.
if all(zeroDiff)
    This = template;
    This.args = 0;
    return
end

switch This.func
    case 'uplus'
        This = mydiff(This.args{1},Wrt);
    case 'uminus'
        This.args{1} = mydiff(This.args{1},Wrt);
    case 'plus'
        pos = find(~zeroDiff);
        nPos = length(pos);
        if nPos == 0
            This = template;
            This.args = 0;
        elseif nPos == 1
            This = mydiff(This.args{pos},Wrt);
        else
            args = cell(1,nPos);
            for i = 1 : nPos
                args{i} = mydiff(This.args{pos(i)},Wrt);
            end
            This.args = args;
        end
    case 'minus'
        if zeroDiff(1)
            This.func = 'uminus';
            This.args = {mydiff(This.args{2},Wrt)};
        elseif zeroDiff(2)
            This = mydiff(This.args{1},Wrt);
        else
            This.args{1} = mydiff(This.args{1},Wrt);
            This.args{2} = mydiff(This.args{2},Wrt);
        end
    case 'times'
        if zeroDiff(1)
            This.args{2} = mydiff(This.args{2},Wrt);
        elseif zeroDiff(2)
            This.args{1} = mydiff(This.args{1},Wrt);
        else
            % mydiff(x1*x2) = mydiff(x1)*x2 + x1*mydiff(x2)
            % Z1 := mydiff(x1)*x2
            % Z2 := x1*mydiff(x2)
            % this := Z1 + Z2
            Z1 = template;
            Z1.func = 'times';
            Z1.args = {mydiff(This.args{1},Wrt), This.args{2}};
            Z2 = template;
            Z2.func = 'times';
            Z2.args = {This.args{1}, mydiff(This.args{2},Wrt)};
            This.func = 'plus';
            This.args = {Z1,Z2};
        end
    case 'rdivide'
        % mydiff(x1/x2)
        if zeroDiff(1)
            This = doRdivide1();
        elseif zeroDiff(2)
            This = doRdivide2();
        else
            Z1 = doRdivide1();
            Z2 = doRdivide2();
            This.func = 'plus';
            This.args = {Z1,Z2};
        end
    case 'log'
        % mydiff(log(x1)) = mydiff(x1)/x1
        This.func = 'rdivide';
        This.args = {mydiff(This.args{1},Wrt),This.args{1}};
    case 'exp'
        % mydiff(exp(x1)) = exp(x1)*mydiff(x1)
        This.args = {mydiff(This.args{1},Wrt),This};
        This.func = 'times';
    case 'power'
        if zeroDiff(1)
            % mydiff(x1^x2) with mydiff(x1) = 0
            % mydiff(x1^x2) = x1^x2 * log(x1) * mydiff(x2)
            This = doPower1();
        elseif zeroDiff(2)
            % mydiff(x1^x2) with mydiff(x2) = 0
            % mydiff(x1^x2) = x2*x1^(x2-1)*mydiff(x1)
            This = doPower2();
        else
            Z1 = doPower1();
            Z2 = doPower2();
            This.func = 'plus';
            This.args = {Z1,Z2};
        end
    case 'sqrt'
        % mydiff(sqrt(x1)) = (1/2) / sqrt(x1) * mydiff(x1)
        % Z1 : = 1/2
        % Z2 = Z1 / sqrt(x1) = Z1 / this
        % this = Z2 * mydiff(x1)
        Z1 = template;
        Z1.func = '';
        Z1.args = 1/2;
        Z2 = template;
        Z2.func = 'rdivide';
        Z2.args = {Z1,This};
        This.func = 'times';
        This.args = {Z2,mydiff(This.args{1},Wrt)};
    case 'sin'
        Z1 = This;
        Z1.func = 'cos';
        This.func = 'times';
        This.args = {Z1,mydiff(This.args{1},Wrt)};
    case 'cos'
        % mydiff(cos(x1)) = uminus(sin(x)) * mydiff(x1);
        Z1 = This;
        Z1.func = 'sin';
        Z2 = template;
        Z2.func = 'uminus';
        Z2.args = {Z1};
        This.func = 'times';
        This.args = {Z2,mydiff(This.args{1},Wrt)};
    otherwise
        % All other functions -- numerical derivatives.
        % diff(f(x1,x2,...)) = diff(f,1)*diff(x1) + diff(f,2)*diff(x2) + ...
        pos = find(~zeroDiff);
        nPos = length(pos);
        % diff(f,i)*diff(xi)
        if nPos == 1
            Z = doExternalWrtK(pos(1));
        else
            Z = template;
            Z.func = 'plus';
            for k = pos
                Z.args{end+1} = doExternalWrtK(k);
            end
        end
        This = Z;
        
end


% Nested functions...


%**************************************************************************
    
    
    function z = doRdivide1()
        % Compute mydiff(x1/x2) with mydiff(x1) = 0
        % mydiff(x1/x2) = -x1/x2^2 * mydiff(x2)
        % z1 := -x1
        % z2 := 2
        % z3 := x2^z2
        % z4 :=  z1/z3
        % z := z4*mydiff(x2)
        z1 = template;
        z1.func = 'uminus';
        z1.args = This.args(1);
        z2 = template;
        z2.func = '';
        z2.args = 2;
        z3 = template;
        z3.func = 'power';
        z3.args = {This.args{2},z2};
        z4 = template;
        z4.func = 'rdivide';
        z4.args = {z1,z3};
        z = template;
        z.func = 'times';
        z.args = {z4,mydiff(This.args{2},Wrt)};
    end % doRdivide1()


%**************************************************************************
    
    
    function z = doRdivide2()
        % Compute mydiff(x1/x2) with mydiff(x2) = 0
        % diff(x1/x2) = diff(x1)/x2
        z = template;
        z.func = 'rdivide';
        z.args = {mydiff(This.args{1},Wrt),This.args{2}};
    end % doRdivide2()


%**************************************************************************
    
    
    function z = doPower1()
        % Compute diff(x1^x2) with diff(x1) = 0
        % diff(x1^x2) = x1^x2 * log(x1) * diff(x2)
        % z1 := log(x1)
        % z2 := this*z1
        % z := z2*diff(x2)
        z1 = template;
        z1.func = 'log';
        z1.args = This.args(1);
        z2 = template;
        z2.func = 'times';
        z2.args = {This,z1};
        z = template;
        z.func = 'times';
        z.args = {z2,mydiff(This.args{2},Wrt)};
    end % doPower1()


%**************************************************************************
    
    
    function z = doPower2()
        % Compute diff(x1^x2) with diff(x2) = 0
        % diff(x1^x2) = x2*x1^(x2-1)*diff(x1)
        % z1 := 1
        % z2 := x2 - z1
        % z3 := f(x1)^z2
        % z4 := x2*z3
        % z := z4*diff(f(x1))
        z1 = template;
        z1.func = '';
        z1.args = -1;
        z2 = template;
        z2.func = 'plus';
        z2.args = {This.args{2},z1};
        z3 = template;
        z3.func = 'power';
        z3.args = {This.args{1},z2};
        z4 = template;
        z4.func = 'times';
        z4.args = {This.args{2},z3};
        z = template;
        z.func = 'times';
        z.args = {z4,mydiff(This.args{1},Wrt)};
    end % doPower2()


%**************************************************************************
    
    
    function Z = doExternalWrtK(K)
        if strcmp(This.func,'sydney.d')
            z1 = This;
            z1.numd.wrt = [z1.numd.wrt,K];
        else
            z1 = template;
            z1.func = 'sydney.d';
            z1.numd.func = This.func;
            z1.numd.wrt = K;
            z1.args = This.args;
        end
        Z = template;
        Z.func = 'times';
        Z.args = {z1,mydiff(This.args{K},Wrt)};
    end % doExternal()


end
