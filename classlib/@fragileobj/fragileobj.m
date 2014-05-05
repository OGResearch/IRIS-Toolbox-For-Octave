classdef fragileobj
   
    properties
        Offset = NaN;
        Storage = cell(1,0);
        Open = cell(1,0);
        Close = cell(1,0);
    end
    
    methods
        
        % Constructor.
        function This = fragileobj(varargin)
            if length(varargin) >= 1
                C = varargin{1};
                varargin(1) = []; %#ok<NASGU>
                This.Offset = max(irisget('highcharcode'),max(double(C)));
            end
        end
        
        % Destructor.
        function delete(This) %#ok<INUSD>
        end
        
        varargout = charcode(varargin)
        varargout = cleanup(varargin)      
        varargout = isempty(varargin)
        varargout = isnan(varargin)
        varargout = length(varargin)
        varargout = regexppattern(varargin)
        varargout = protectbrackets(varargin)
        varargout = protectbraces(varargin)
        varargout = protectquotes(varargin)
        varargout = restore(varargin)
    end
    
end