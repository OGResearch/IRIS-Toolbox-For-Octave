classdef tsydney < sydney
    
    
    properties
        TRec = [];
        Ref = {};
        InpName = '';
    end
    
    
    methods
        function This = tsydney(varargin)
            if isempty(varargin)
                return
            end
            if length(varargin) == 1 && isa(varargin{1},'tsydney')
                This = varargin{1};
                return
            end
            This.func = '';
            This.args = varargin{1};
            This.lookahead = 0;
            This.numd = [];
            This.InpName = varargin{2};
            This.TRec = varargin{3};
            This.Ref = varargin(4:end);
        end
    end
    
    
    methods
        function C = myatomchar(This)
            tr = This.TRec;
            ref = myprintref(This);
            if tr.Shift == 0
                C = sprintf('?(t%s)',ref);
            else
                C = sprintf('?(t%+g%s)',tr.Shift,ref);
            end
        end        
        
        function C = myprintref(This)
            C = '';
            if isempty(This.Ref)
                return
            end
            for i = 1 : length(This.Ref)
                r = sprintf('%g,',This.Ref{1});
                C = [C,', [',r(1:end-1),']']; %#ok<AGROW>
            end
        end
        
        
        varargout = myeval(varargin)
    end
    
    
end
