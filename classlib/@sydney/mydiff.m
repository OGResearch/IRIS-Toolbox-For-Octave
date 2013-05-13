function this = mydiff(this,wrt)

nwrt = length(wrt);

if isequalwithequalnans(this.lookahead,NaN)
    utils.error('sydney', ...
        ['Cannot evaluate multiple consecutive derivatives ', ...
        'without re-creating the sydney object.']);
end

if isempty(this.func)
    if ischar(this.args)
        % This is a variable name.
        if nwrt == 1
            if strcmp(this.args,wrt)
                this.func = '';
                this.args = 1;
            else
                this.func = '';
                this.args = 0;
            end
        else
            index = strcmp(this.args,wrt);
            if any(index)
                this.func = '';
                this.args = false(nwrt,1);
                this.args(index) = 1;
            else
                this.func = '';
                this.args = 0;
            end
        end
    elseif isnumeric(this.args)
        % This is a number.
        this.func = '';
        this.args = 0;
    else
        utils.error('sydney', ...
            'Unknown type of sydney atom.');
    end
    return
end

%{
if isequal(this.func,'sydney.d')
    utils.error('sydney', ...
        'Cannot compute second or higher derivatives.');
end
%}

% Look ahead to see whether the wrt variables are present in the current
% function's argument legs.
nargs = length(this.args);
zerodiff = true(1,nargs);
for i = 1 : nargs
    for j = 1 : nwrt
        zerodiff(i) = zerodiff(i) ...
            && ~any(strcmp(this.lookahead{i},wrt{j}));
    end
end

% Nullify lookahaed information after differentiation.
this.lookahead = {};

% None of the wrt variables occurs in the function's argument legs.
if all(zerodiff)
    this.func = '';
    this.args = 0;
    return
end

template = sydney();

switch this.func
    case {'uplus','uminus'}
        this.args{1} = mydiff(this.args{1},wrt);
    case 'plus'
        if zerodiff(1)
            this = mydiff(this.args{2},wrt);
        elseif zerodiff(2)
            this = mydiff(this.args{1},wrt);
        else
            this.args{1} = mydiff(this.args{1},wrt);
            this.args{2} = mydiff(this.args{2},wrt);
        end
    case 'minus'
        if zerodiff(1)
            this.func = 'uminus';
            this.args = {mydiff(this.args{2},wrt)};
        elseif zerodiff(2)
            this = mydiff(this.args{1},wrt);
        else
            this.args{1} = mydiff(this.args{1},wrt);
            this.args{2} = mydiff(this.args{2},wrt);
        end
    case 'times'
        if zerodiff(1)
            this.args{2} = mydiff(this.args{2},wrt);
        elseif zerodiff(2)
            this.args{1} = mydiff(this.args{1},wrt);
        else
            % mydiff(x1*x2) = mydiff(x1)*x2 + x1*mydiff(x2)
            % Z1 := mydiff(x1)*x2
            % Z2 := x1*mydiff(x2)
            % this := Z1 + Z2
            Z1 = template;
            Z1.func = 'times';
            Z1.args = {mydiff(this.args{1},wrt), ...
                this.args{2}};
            Z2 = template;
            Z2.func = 'times';
            Z2.args = {this.args{1}, ...
                mydiff(this.args{2},wrt)};
            this.func = 'plus';
            this.args = {Z1,Z2};
        end
    case 'rdivide'
        % mydiff(x1/x2)
        if zerodiff(1)
            this = dordivide1();
        elseif zerodiff(2)
            this = dordivide2();
        else
            Z1 = dordivide1();
            Z2 = dordivide2();
            this.func = 'plus';
            this.args = {Z1,Z2};
        end
    case 'log'
        % mydiff(log(x1)) = mydiff(x1)/x1
        this.func = 'rdivide';
        this.args = {mydiff(this.args{1},wrt),this.args{1}};
    case 'exp'
        % mydiff(exp(x1)) = exp(x1)*mydiff(x1)
        this.args = {mydiff(this.args{1},wrt),this};
        this.func = 'times';
    case 'power'
        if zerodiff(1)
            % mydiff(x1^x2) with mydiff(x1) = 0
            % mydiff(x1^x2) = x1^x2 * log(x1) * mydiff(x2)
            this = dopower1();
        elseif zerodiff(2)
            % mydiff(x1^x2) with mydiff(x2) = 0
            % mydiff(x1^x2) = x2*x1^(x2-1)*mydiff(x1)
            this = dopower2();
        else
            Z1 = dopower1();
            Z2 = dopower2();
            this.func = 'plus';
            this.args = {Z1,Z2};
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
        Z2.args = {Z1,this};
        this.func = 'times';
        this.args = {Z2,mydiff(this.args{1},wrt)};
    case 'sin'
        Z1 = this;
        Z1.func = 'cos';
        this.func = 'times';
        this.args = {Z1,mydiff(this.args{1},wrt)};
    case 'cos'
        % mydiff(cos(x1)) = uminus(sin(x)) * mydiff(x1);
        Z1 = this;
        Z1.func = 'sin';
        Z2 = template;
        Z2.func = 'uminus';
        Z2.args = {Z1};
        this.func = 'times';
        this.args = {Z2,mydiff(this.args{1},wrt)};
    otherwise
        % External function.
        % diff(f(x1,x2,...)) = diff(f,1)*diff(x1) + diff(f,2)*diff(x2) + ...
        if strcmp(this.func,'sydney.d')
            zerodiff(1:2) = true;
        end
        pos = find(~zerodiff);
        % diff(f,i)*diff(xi)
        Z = dodiffxf(pos(1));
        for i = pos(2:end)
            Z1 = Z;
            Z.func = 'plus';
            Z.args = {Z1,dodiffxf(i)};
        end
        this = Z;
        
end

% Nested functions.

    function z = dordivide1()
        % Compute mydiff(x1/x2) with mydiff(x1) = 0
        % mydiff(x1/x2) = -x1/x2^2 * mydiff(x2)
        % z1 := -x1
        % z2 := 2
        % z3 := x2^z2
        % z4 :=  z1/z3
        % z := z4*mydiff(x2)
        z1 = template;
        z1.func = 'uminus';
        z1.args = this.args(1);
        z2 = template;
        z2.func = '';
        z2.args = 2;
        z3 = template;
        z3.func = 'power';
        z3.args = {this.args{2},z2};
        z4 = template;
        z4.func = 'rdivide';
        z4.args = {z1,z3};
        z = template;
        z.func = 'times';
        z.args = {z4,mydiff(this.args{2},wrt)};
    end

    function z = dordivide2()
        % Compute mydiff(x1/x2) with mydiff(x2) = 0
        % diff(x1/x2) = diff(x1)/x2
        z = template;
        z.func = 'rdivide';
        z.args = {mydiff(this.args{1},wrt),this.args{2}};
    end

    function z = dopower1()
        % Compute diff(x1^x2) with diff(x1) = 0
        % diff(x1^x2) = x1^x2 * log(x1) * diff(x2)
        % z1 := log(x1)
        % z2 := this*z1
        % z := z2*diff(x2)
        z1 = template;
        z1.func = 'log';
        z1.args = this.args(1);
        z2 = template;
        z2.func = 'times';
        z2.args = {this,z1};
        z = template;
        z.func = 'times';
        z.args = {z2,mydiff(this.args{2},wrt)};
    end

    function z = dopower2()
        % Compute diff(x1^x2) with diff(x2) = 0
        % diff(x1^x2) = x2*x1^(x2-1)*diff(x1)
        % z1 := 1
        % z2 := x2 - z1
        % z3 := f(x1)^z2
        % z4 := x2*z3
        % z := z4*diff(f(x1))
        z1 = template;
        z1.func = '';
        z1.args = 1;
        z2 = template;
        z2.func = 'minus';
        z2.args = {this.args{2},z1};
        z3 = template;
        z3.func = 'power';
        z3.args = {this.args{1},z2};
        z4 = template;
        z4.func = 'times';
        z4.args = {this.args{2},z3};
        z = template;
        z.func = 'times';
        z.args = {z4,mydiff(this.args{1},wrt)};
    end

    function z = dodiffxf(k)
        if strcmp(this.func,'sydney.d')
            z1 = this;
            wrtk = z1.args{2};
            wrtk.args(end+1) = k - 2;
            z1.args{2} = wrtk;
        else
            z1 = template;
            z1.func = 'sydney.d';
            wrtk = template;
            wrtk.func = '';
            wrtk.args = k;
            z1.args = {str2func(this.func),wrtk,this.args{:}}; %#ok<CCAT>
        end
        z = template;
        z.func = 'times';
        z.args = {z1,mydiff(this.args{k},wrt)};
    end

end