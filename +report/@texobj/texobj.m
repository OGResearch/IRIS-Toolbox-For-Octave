classdef texobj < report.userinputobj
    
    properties
    end
    
    methods
        
        function This = texobj(varargin)
            This = This@report.userinputobj(varargin{:});
            This.default = [This.default,{ ...
                'separator','\medskip\par',@ischar,true, ...
                'verbatim',false,@islogicalscalar,true, ...
                }];
        end
        
        function [This,varargin] = specargin(This,varargin)
            % If the number of input arguments behind `Cap` is odd and the first input
            % argument after `Cap` is char, we grab it as input code/text; otherwise we
            % grab the comment block from caller.
            if mod(length(varargin),2) == 1 && ischar(varargin{1})
                This.userinput = varargin{1};
                varargin(1) = [];
            else
                caller = dbstack('-completenames');
                if length(caller) >= 4
                    This.userinput = preparser.grabcommentblk(caller(4));
                end
            end
        end
        
    end
    
    methods (Access=protected,Hidden)
        
        varargout = speclatexcode(varargin)
        
    end
    
end