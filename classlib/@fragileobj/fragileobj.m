classdef fragileobj
   
    properties
        Offset = NaN;
        Store = cell(1,0);
        Open = cell(1,0);
        Close = cell(1,0);
    end
    
    properties (Constant)
        % General pattern.
        GPattern = [char(2),'[',char(16),'-',char(25),']+',char(3)];
        CharUsed = [ ...
            char(2), ...
            char(3), ...
            char(16), ...
            char(17), ...
            char(18), ...
            char(19), ...
            char(20), ...
            char(21), ...
            char(22), ...
            char(23), ...
            char(24), ...
            char(25), ...
            ];
    end
    
    methods
        % Constructor.
        function This = fragileobj(varargin)
            if length(varargin) ~= 1
                return
            end
            c = regexp(varargin{1},This.GPattern,'match');
            if isempty(c)
                This.Offset = 0;
            else
                x = fragileobj.char2dec(c);
                This.Offset = max(x);
            end
        end
        
        
        % Destructor.
        function delete(This) %#ok<INUSD>
        end
        
        
        varargout = charcode(varargin)
        varargout = cleanup(varargin) 
        varargout = copytoend(varargin)
        varargout = dec2char(varargin)
        varargout = isempty(varargin)
        varargout = isnan(varargin)
        varargout = length(varargin)
        varargout = regexppattern(varargin)
        varargout = protectbrackets(varargin)
        varargout = protectbraces(varargin)
        varargout = protectquotes(varargin)
        varargout = restore(varargin)
    end

    
    methods (Static)
        varargout = char2dec(varargin)
    end
    
end