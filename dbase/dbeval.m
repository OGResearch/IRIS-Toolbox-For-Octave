function varargout = dbeval(D,varargin)
% dbeval  Evaluate expression in specified database.
%
% Syntax
% =======
%
%     [Value1,Value2,...] = dbeval(D,Expr1,Expr2,...)
%     [Value1,Value2,...] = dbeval(M,Expr1,Expr2,...)
%
%
% Syntax with steady-state references
% ====================================
%
%     [Value1,Value2,...] = dbeval(D,SS,Expr1,Expr2,...)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database within which the expressions will be
% evaluated.
%
% * `M` [ model ] - Model object whose steady-state database will be used
% to evaluate the expression.
%
% * `Expr1`, `Expr2`, ... [ char ] - Expressions that will be evaluated
% using the fields of the input database.
%
% Output arguments
% =================
%
% * `Value1`, `Value2`, ... [ ... ] - Resulting values.
%
% Description
% ============
%
% Example
% ========
%
% Create a database with two fields and one subdatabase with one field,
%
%     d = struct();
%     d.a = 1;
%     d.b = 2;
%     d.dd = struct();
%     d.dd.c = 3;
%     display(d)
%     d =
%        a: 1
%        b: 2
%        c: [1x1 struct]
%
% Use the `dbeval` function to evaluate an expression within the database
%
%     dbeval(d,'a+b+dd.c')
%     ans =
%           7
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if false % ##### MOSW
    className = 'modelobj';
else
    className = 'model'; %#ok<UNRCH>
end

if ~isempty(varargin) ...
        && (isstruct(varargin{1}) || isa(varargin{1},className))
    SS = varargin{1};
    varargin(1) = [];
else
    SS = struct([]);
end

% Parse required input arguments.
pp = inputParser();
pp.addRequired('D',@(x) isstruct(x) || ismodel(x));
pp.addRequired('SS',@(x) isstruct(x) || ismodel(x));
pp.addRequired('Expr',@(x) isempty(x) || iscellstr(x{1}) || iscellstr(x));
pp.parse(D,SS,varargin);

if isempty(varargin)
    varargout = {};
    return
elseif iscellstr(varargin{1})
    expr = varargin{1};
    multiple = false;
else
    expr = varargin;
    multiple = true;
end

if isa(D,'model')
    D = get(D,'sstateLevel');
end

if isa(SS,'model')
    SS = get(SS,'sstateLevel');
end

%--------------------------------------------------------------------------

expr = strtrim(expr);
list1 = fieldnames(D).';
list2 = fieldnames(SS).';
prefix1 = [char(1),'.'];
prefix2 = [char(2),'.'];
for i = 1 : length(list2)
    expr = regexprep(expr,['&\<',list2{i},'\>'],[prefix2,list2{i}]);
end
for i = 1 : length(list1)
    expr = regexprep(expr,['(?<!\.)\<',list1{i},'\>'],[prefix1,list1{i}]);
end

expr = strrep(expr,prefix1,'D.');
expr = strrep(expr,prefix2,'SS.');

% Replace all possible assignments and equal signs used in IRIS codes.
% Non-linear simulation earmarks.
expr = strrep(expr,'==','=');
expr = strrep(expr,'=#','=');
% Dtrend equations.
expr = strrep(expr,'+=','=');
expr = strrep(expr,'*=','=');
% Identities.
expr = strrep(expr,':=','=');

% Convert x=y and x+=y into x-(y) so that we can evaluate LHS minus RHS.
% Note that using strrep is faster than regexprep.
index = strfind(expr,'=');
for i = 1 : length(index)
    if length(index{i}) == 1
        % Remove trailing colons.
        if expr{i}(end) == ';'
            expr{i}(end) = '';
        end
        expr{i} = [expr{i}(1:index{i}-1),'-(',expr{i}(index{i}+1:end),')'];
    end
end

varargout = cell(size(expr));
for i = 1 : length(expr)
    try
        varargout{i} = eval(expr{i});
    catch %#ok<CTCH>
        varargout{i} = NaN;
    end
end

if ~multiple
    varargout{1} = varargout;
    varargout(2:end) = [];
end

end
