classdef getsetobj
    
    properties
    end
    
    methods
        
        function This = getsetobj(varargin)
        end
        
        varargout = get(varargin)
        
    end
    
    methods (Static,Access=protected,Hidden)
        
        varargout = myalias(varargin)
        
    end
    
end