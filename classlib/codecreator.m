classdef codecreator < handle
    
    properties
        Code = '';
        indentString = '   ';
        autoIndent = 0;
    end
    
    methods
        function This = codecreator(varargin)
            if ~isempty(varargin)
                This.indentString = varargin{1};
            end
        end
        function This = nl(This,varargin)
            if isempty(varargin) || ~isnumericscalar(varargin{1})
                nNl = 1;
            else
                nNl = varargin{1};
            end
            nl = sprintf('\n');
            This.Code = [This.Code,nl(ones([1,nNl]))];
        end
        function [This,varargin] = indent(This,varargin)
            if isempty(varargin) || ~isnumericscalar(varargin{1})
                nIndent = 1;
            else
                nIndent = varargin{1};
                varargin(1) = [];
            end
            for i = 1 : nIndent
                This.Code = [This.Code,This.indentString];
            end
        end
        function This = print(This,varargin)
            if This.autoIndent > 0
                This = indent(This,This.autoIndent);
            end
            if length(varargin) == 1
                This.Code = [This.Code,varargin{1}];
            else
                This.Code = [This.Code,sprintf(varargin{:})];
            end
        end
        function This = printn(This,varargin)
            This = print(This,varargin{:});
            This = nl(This);
        end
        function This = nprint(This,varargin)
            This = nl(This);
            This = print(This,varargin{:});
        end
        function This = iprint(This,varargin)
            [This,varargin] = indent(This,varargin{:});
            This = print(This,varargin{:});
        end
        function This = iprintn(This,varargin)
            [This,varargin] = indent(This,varargin{:});
            This = print(This,varargin{:});
            This = nl(This);
        end
        function This = niprint(This,varargin)
            This = nl(This);
            [This,varargin] = indent(This,varargin{:});
            This = print(This,varargin{1});
        end
        function save(This,filename)
            char2file(This.Code,filename);
        end
    end
    
end
