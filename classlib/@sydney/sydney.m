classdef sydney
    % SYDNEY  [Not a public class] Automatic first-order differentiator.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2014 IRIS Solutions Team.
    
    properties
        func = '';
        args = cell(1,0);
        lookahead = [];
        numd = [];
    end
    
    methods
        function This = sydney(varargin)
            if isempty(varargin)
                return
                
            elseif length(varargin) == 1 && isa(varargin{1},'sydney')
                
                % Sydney object.
                This = varargin{1};
                return
                
            else
                
                expn = varargin{1};
                wrt = varargin{2};
                
                if isnumeric(expn)
                    
                    % Plain number.
                    This.func = '';
                    This.args = expn;
                    This.lookahead = false;
                    
                elseif ischar(expn)
                    
                    if isvarname(expn)
                        
                       % Single variable name.
                        This.func = '';
                        This.args = expn;
                        This.lookahead = any(strcmp(expn,wrt));
                        
                    else
                        
                        % General expression.
                        template = sydney();
                        expr = strtrim(expn);
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
                        %z(:) = {template};
                        for i = 1 : nVar
                            name = varList{i};
                            z{i} = template;
                            z{i}.args = name;
                            z{i}.lookahead = any(strcmp(name,wrt));
                        end
                        
                        % Create an anonymous function for the expression.
                        % The function's preamble includes all variable
                        % names found in the equation.
                        preamble = sprintf('%s,',varList{:});
                        preamble = ['@(',preamble(1:end-1),')'];
                        if ismatlab
                            tempFunc = str2func([preamble,expr]);
                        else
                            tempFunc = mystr2func([preamble,expr]);
                        end
                        
                        % Evaluate the equation's function handle on the
                        % sydney objects.
                        x = tempFunc(z{:});
                                                
                        if isa(x,'sydney')
                            This = x;
                        elseif isnumeric(x)
                            This.func = '';
                            This.args = x;
                            This.lookahead = false;
                        else
                            utils.error('sydney', ...
                                'Cannot create a sydney object.');
                        end
                        
                    end
                end
                
            end
        end
        
        varargout = uminus(varargin)
        varargout = plus(varargin)
        varargout = times(varargin)
        varargout = rdivide(varargin)
        varargout = power(varargin)
        
        varargout = diff(varargin)
        varargout = mydiff(varargin)
        varargout = reduce(varargin)
        varargout = char(varargin)
        
        function This = uplus(A)
            This = A;
        end

        function This = minus(A,B)
            % Replace x - y with x + (-y) to include minus as a special case in plus
            % with multiple arguments.
            This = plus(A,uminus(B));
        end
        
        function This = mtimes(A,B)
            This = times(A,B);
        end
        
        function This = mrdivide(A,B)
            This = rdivide(A,B);
        end
        function This = ldivide(A,B)
            This = rdivide(B,A);
        end
        function This = mldivide(A,B)
            This = rdivide(B,A);
        end
        
        function This = mpower(A,B)
            This = power(A,B);
        end
        
        function This = gt(varargin)
            This = sydney.parse('gt',varargin{:});
        end
        
        function This = ge(varargin)
            This = sydney.parse('ge',varargin{:});
        end
        
        function This = lt(varargin)
            This = sydney.parse('lt',varargin{:});
        end
        
        function This = le(varargin)
            This = sydney.parse('le',varargin{:});
        end
        
        function This = eq(varargin)
            This = sydney.parse('eq',varargin{:});
        end

        function Flag = isnumber(Z)
            Flag = isempty(Z.func) && is.numericscalar(Z.args);
        end
        
    end
    
    methods (Static)
        
        varargout = d(varargin)
        varargout = mydiffeqtn(varargin)
        varargout = myshift(varargin)
        varargout = mysymb2eqtn(varargin)
        varargout = myeqtn2symb(varargin)
        varargout = parse(varargin)

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