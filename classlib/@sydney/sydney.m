classdef sydney
    % SYDNEY  [Not a public class] Automatic first-order differentiator.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.
    
    properties
        func = '';
        args = {};
        lookahead = {};
    end
    
    methods
        function This = sydney(varargin)
            if isempty(varargin)
                return
            elseif length(varargin) == 1
                if isa(varargin{1},'sydney')
                    This = varargin{1};
                elseif isnumeric(varargin{1})
                    This.func = '';
                    This.args = varargin{1};
                elseif ischar(varargin{1})
                    if isvarname(varargin{1})
                        This.func = '';
                        This.args = varargin{1};
                    else
                        template = sydney();
                        expr = strtrim(varargin{1});
                        if isempty(expr)
                            This.func = '';
                            This.args = 0;
                            return
                        end
                        
                        % Remove anonymous function header @(...) if present.
                        if strncmp(expr,'@(',2);
                            expr = regexprep(expr,'@\(.*?\)','');
                        end
                        
                        % Find all variables names.
                        varList = regexp(expr, ...
                            '(?<!@)(\<[a-zA-Z]\w*\>)(?!\()','tokens');
                        
                        % Validate function names in the equation. Function
                        % not handled by the sydney class will be evaluated
                        % by a call to sydney.parse().
                        expr = sydney.callfunc(expr);
                        if ~isempty(varList)
                            varList = unique([varList{:}]);
                        end
                        
                        % Create a sydney object for each variables name.
                        nVar = length(varList);
                        z = cell(1,nVar);
                        for i = 1 : nVar
                            z{i} = template;
                            z{i}.func = '';
                            z{i}.args = varList{i};
                        end
                        
                        % Create an anonymous function for the expression.
                        % The function's preamble includes all variable
                        % names found in the equation.
                        preamble = sprintf('%s,',varList{:});
                        preamble = ['@(',preamble(1:end-1),')'];
                        tempFunc = str2func([preamble,expr]);
                        
                        % Evaluate the equation's function handle on the
                        % sydney objects.
                        x = tempFunc(z{:});
                        if isa(x,'sydney')
                            This = x;
                        elseif isnumeric(x)
                            This.func = '';
                            This.args = x;
                        else
                            utils.error('sydney', ...
                                'Cannot create a sydney object.');
                        end
                    end
                end
            else
                This.func = varargin{1};
                This.args = varargin{2};
            end
        end
        
        % Functional forms of unary and binary operators that can take
        % non-functional forms.

        function this = uplus(varargin)
            this = sydney.parse('uplus',varargin{:});
        end
        function this = uminus(varargin)
            this = sydney.parse('uminus',varargin{:});
        end
        function this = plus(varargin)
            this = sydney.parse('plus',varargin{:});
        end
        function this = minus(varargin)
            this = sydney.parse('minus',varargin{:});
        end
        function this = times(varargin)
            this = sydney.parse('times',varargin{:});
        end
        function this = mtimes(varargin)
            this = sydney.parse('times',varargin{:});
        end
        function this = rdivide(varargin)
            this = sydney.parse('rdivide',varargin{:});
        end
        function this = mrdivide(varargin)
            this = sydney.parse('rdivide',varargin{:});
        end
        function this = ldivide(varargin)
            this = sydney.parse('rdivide',varargin{[2,1]});
        end
        function this = mldivide(varargin)
            this = sydney.parse('rdivide',varargin{[2,1]});
        end
        function this = power(varargin)
            this = sydney.parse('power',varargin{:});
        end
        function this = mpower(varargin)
            this = sydney.parse('power',varargin{:});
        end
        function this = gt(varargin)
            this = sydney.parse('gt',varargin{:});
        end
        function this = ge(varargin)
            this = sydney.parse('ge',varargin{:});
        end
        function this = lt(varargin)
            this = sydney.parse('lt',varargin{:});
        end
        function this = le(varargin)
            this = sydney.parse('le',varargin{:});
        end
        function this = eq(varargin)
            this = sydney.parse('eq',varargin{:});
        end

        function flag = isatom(z)
            flag = isempty(z.func) || isequal(z.func,'sydney.d');
        end
        
        function flag = isnumber(z)
            flag = isempty(z.func) && isnumericscalar(z.args);
        end
        
        varargout = diff(varargin)
        varargout = reduce(varargin)
        varargout = char(varargin)
        
    end
    
    methods (Access=protected)
        varargout = mydiff(varargin)
    end
    
    methods (Static)
        
        varargout = d(varargin)
        varargout = mydiffeqtn(varargin)
        varargout = mysymb2eqtn(varargin)
        varargout = myeqtn2symb(varargin)
        varargout = parse(varargin)

        varargout = testme(varargin)        
        
        function Expr = callfunc(Expr)
            % Find all function names. Function names may also include dots to allow
            % for methods and packages. Functions with no input arguments are not
            % parsed and remain unchanged.
            funcList = regexp(Expr, ...
                '\<[a-zA-Z][\w\.]*\>\((?!\))','match');
            funcList = unique(funcList);
            % Find function names that are not handled by the sydney
            % class.
            for i = 1 : length(funcList)
                funcname = funcList{i}(1:end-1);
                Expr = regexprep(Expr,['\<',funcname,'\>('], ...
                    ['sydney.parse(''',funcname,''',']);
            end
        end
        
        % For bkw compatibility.
        
        function varargout = diffxf(varargin)
            [varargout{1:nargout}] = sydney.d(varargin{:});
        end
        
        function varargout = numdiff(varargin)
            [varargout{1:nargout}] = sydney.d(varargin{:});
        end
        
    end
    
end