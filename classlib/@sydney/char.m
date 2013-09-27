function c = char(this,flag)
% char  Print sydney object as text string expression.
%
% Syntax
% =======
%
%     C = char(Z)
%     C = char(Z,'human')
%     C = char(Z,'bsx')
%
% Input arguments
% ================
%
% * `Z` [ sydney ] - Sydney object.
%
% Output arguments
% =================
%
% * `C` [ char ] - Text string with an expression representing the input
% sydney object.
%
% Description
% ============
%
% The flag `'human'` makes the +, -, *, /, \, and ^ operators appear as
% binary operators and not as functions.
%
% The flag `'bsx'` makes all functions and operators appear inside a `bsxfun`
% function, see help on `bsxfun` for more details.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

human = false;
bsx = false;

if exist('flag','var')
    human = strcmp(flag,'human');
    bsx = strcmp(flag,'bsx');
else
    flag = '';
end

switch this.func
    case ''
        c = xxatom2char(this.args);
    case 'sydney.d'
        % Differentiate an external function.
        c = ['sydney.d(@',func2str(this.args{1})];
        for i = 2 : length(this.args)
            c = [c,',',xxargs2char(this.args{i},flag)]; %#ok<AGROW>
        end
        c = [c,')'];
    otherwise
        nargs = length(this.args);
        if nargs == 1
            c1 = xxargs2char(this.args{1},flag);
            done = false;
            if human
                switch this.func
                    case 'uplus'
                        sign = '';
                        done = true;
                    case 'uminus'
                        sign = '-';
                        done = true;
                end
                if done
                    if ~isatom(this.args{1})
                        c1 = ['(',c1,')'];
                    end
                    c = [sign,c1];
                end
            end
            if ~done
                c = [this.func,'(',c1,')'];
            end
        elseif nargs == 2 && ~bsx
            c1 = xxargs2char(this.args{1},flag);
            c2 = xxargs2char(this.args{2},flag);
            done = false;
            if human
                switch this.func
                    case 'plus'
                        sign = '+';
                        done = true;
                    case 'minus'
                        sign = '-';
                        done = true;
                    case 'times'
                        sign = '*';
                        done = true;
                    case 'rdivide'
                        sign = '/';
                        done = true;
                    case 'power'
                        sign = '^';
                        done = true;
                    case 'lt'
                        sign = '<';
                        done = true;
                    case 'le'
                        sign = '<=';
                        done = true;
                    case 'gt'
                        sign = '>';
                        done = true;
                    case 'ge'
                        sign = '>=';
                        done = true;
                    case 'eq'
                        sign = '==';
                        done = true;
                end
                if done
                    if ~(isatom(this.args{1}) && isatom(this.args{2}))
                        c1 = ['(',c1,')'];
                        c2 = ['(',c2,')'];
                    end
                    c = [c1,sign,c2];
                end
            end
            if ~done
                c = [this.func,'(',c1,',',c2,')'];
            end
        else
            if ~bsx
                c = [this.func,'(',];
            else
                c = ['bsxfun(@',this.func,','];
            end
            c = [c,xxargs2char(this.args{1},flag)];
            for i = 2 : nargs
                c = [c,',',xxargs2char(this.args{i},flag)]; %#ok<AGROW>
            end
            c = [c,')'];
        end
        
end

end

%**************************************************************************
function c = xxargs2char(x,flag)
    if isa(x,'sydney')
        c = char(x,flag);
    elseif isfunc(x)
        c = ['@',func2str(x)];
    elseif ischar(x)
        c = ['''',x,''''];
    else
        utils.error('sydney', ...
            'Invalid type of function argument in a sydney expression.');
    end
end
% xxchar().

%**************************************************************************
function c = xxatom2char(a)

prec = 15;

if ischar(a)
    % Name of a variable.
    c = a;
elseif isnumericscalar(a)
    % Numerical constant.
    c = sprintf('%.*g',prec,a);
elseif isnumeric(a)
    c = mat2str(a,prec);
elseif islogical(a)
    % Vector of 0s and 1s indicating derivatives wrt individual variables.
    c1 = sprintf('%g;',a);
    c1(end) = '';
    c = ['[',c1,']'];
else
    utils.error('sydney', ...
        'Unknown type of sydney atom.');
end

end
% xxatom2char().