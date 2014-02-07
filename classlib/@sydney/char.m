function C = char(This,Flag)
% char  Print sydney object as text string expression.
%
% Syntax
% =======
%
%     C = char(Z)
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
% The flag `'bsx'` makes all functions and operators appear inside a
% `bsxfun` function, see help on `bsxfun` for more details.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

persistent PLUSPREC TIMESPREC UMINUSPREC;
if isempty(PLUSPREC) || isempty(TIMESPREC)
    PLUSPREC = {'le','lt','ge','gt','eq'};
    TIMESPREC = [{'rdivide','plus','minus'},PLUSPREC];
    UMINUSPREC = [{'times'},TIMESPREC];
end

%--------------------------------------------------------------------------

try
    bsx = strcmp(Flag,'bsx');
catch
    Flag = '';
    bsx = false;
end

if isempty(This.func)
    % Atomic value.
    C = xxAtom2Char(This.args);
    return
end

if strcmp(This.func,'sydney.d')
    % Derivative of an external function.
    C = ['sydney.d(@',This.numd.func];
    wrt = sprintf(',%g',This.numd.wrt);
    wrt = ['[',wrt(2:end),']'];
    C = [C,',',wrt];
    for i = 1 : length(This.args)
        C = [C,',',xxArgs2Char(This.args{i},Flag)]; %#ok<AGROW>
    end
    C = [C,')'];
    return
end

nArg = length(This.args);

if strcmp(This.func,'plus')
    doPlus();
    return
end

if strcmp(This.func,'times')
    doTimes();
    return
end

if nArg == 1
    c1 = xxArgs2Char(This.args{1},Flag);
    switch This.func
        case 'uplus'
            C = c1;
        case 'uminus'
            if ischar(This.args{1}.func) ...
                    && any(strcmp(This.args{1}.func,UMINUSPREC))
                c1 = ['(',c1,')'];
            end
            C = ['-',c1];
        otherwise
            C = [This.func,'(',c1,')'];
    end
elseif nArg == 2 && ~bsx
    c1 = xxArgs2Char(This.args{1},Flag);
    c2 = xxArgs2Char(This.args{2},Flag);
    isFinished = false;
    switch This.func
        case 'minus'
            sign = '-';
        case 'rdivide'
            sign = '/';
        case 'power'
            sign = '^';
        case 'lt'
            sign = '<';
        case 'le'
            sign = '<=';
        case 'gt'
            sign = '>';
        case 'ge'
            sign = '>=';
        case 'eq'
            sign = '==';
        otherwise
            C = [This.func,'(',c1,',',c2,')'];
            isFinished = true;
    end
    if ~isFinished
        if ~isempty(This.args{1}.func) ...
                && ~strcmp(This.args{1}.func,'sydney.d')
            c1 = ['(',c1,')'];
        end
        if ~isempty(This.args{2}.func) ...
                && ~strcmp(This.args{2}.func,'sydney.d')
            c2 = ['(',c2,')'];
        end
        C = [c1,sign,c2];
    end
else
    if ~bsx
        C = [This.func,'(',];
    else
        C = ['bsxfun(@',This.func,','];
    end
    C = [C,xxArgs2Char(This.args{1},Flag)];
    for i = 2 : nArg
        C = [C,',',xxArgs2Char(This.args{i},Flag)]; %#ok<AGROW>
    end
    C = [C,')'];
end


% Nested functions.


%**************************************************************************
    function doPlus()
        C = '';
        for iiArg = 1 : nArg
            sign = '+';
            a = This.args{iiArg};
            if strcmp(a.func,'uminus')
                c = xxArgs2Char(a.args{1},Flag);
                if ischar(a.args{1}.func) ...
                        && any(strcmp(a.args{1}.func,UMINUSPREC))
                    c = ['(',c,')']; %#ok<AGROW>
                end
                sign = '-';
            elseif isempty(a.func) && isnumeric(a.args) ...
                    && all(a.args < 0)
                c = xxAtom2Char(-a.args);
                sign = '-';
            else
                c = xxArgs2Char(a,Flag);
                if any(strcmp(a.func,PLUSPREC))
                    c = ['(',c,')']; %#ok<AGROW>
                end
            end
            C = [C,sign,c]; %#ok<AGROW>
        end
        if C(1) == '+'
            C(1) = '';
        end
    end % doPlus()


%**************************************************************************
    function doTimes()
        C = '';
        for iiArg = 1 : nArg
            sign = '*';
            a = This.args{iiArg};
            c = xxArgs2Char(a,Flag);
            if any(strcmp(a.func,TIMESPREC))
                c = ['(',c,')']; %#ok<AGROW>
            end
            C = [C,sign,c]; %#ok<AGROW>
        end
        if C(1) == '*'
            C(1) = '';
        end
    end % doTimes()


end


% Subfunctions.


%**************************************************************************
function C = xxArgs2Char(X,Flag)

if isa(X,'sydney')
    C = char(X,Flag);
elseif is.func(X)
    C = ['@',func2str(X)];
elseif ischar(X)
    C = ['''',X,''''];
else
    utils.error('sydney:char', ...
        'Invalid type of function argument in a sydney expression.');
end

end % xxArgs2Char()


%**************************************************************************
function C = xxAtom2Char(A)

fmt = '%.15g';
if ischar(A)
    % Name of a variable.
    C = A;
elseif is.numericscalar(A)
    % Constant.
    if A == 0
        C = '0';
    else
        C = sprintf(fmt,A);
    end
elseif (isnumeric(A) || islogical(A)) ...
        && ~isempty(A) && length(size(A)) == 2 && size(A,2) == 1
    % Column vector.
    C = sprintf([';',fmt],double(A));
    C = ['[',C(2:end),']'];
else
    utils.error('sydney:char', ...
        'Unknown type of sydney atom.');
end

end % xxAtom2Char().