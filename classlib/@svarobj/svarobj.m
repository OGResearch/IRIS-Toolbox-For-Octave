classdef svarobj
    
    properties
        B = []; % Coefficient matrix in front of structural residuals.
        Std = []; % Std dev of structural residuals.
        Method = {}; % Identification method.
        Rank = Inf;
    end
    
    methods
        
        function This = svarobj(varargin)
            if isempty(varargin)
                return
            end
            if length(varargin) == 1 && isa(varargin{1},'svarobj')
                This = varargin{1};
                return
            end
        end
        
    end
    
    methods
        varargout = irf(varargin)      
        varargout = fevd(varargin)
        varargout = sort(varargin)
        varargout = srf(varargin)
    end
    
    methods (Hidden)
        varargout = myidentify(varargin)
        varargout = mystructuralshocks(varargin)
        varargout = specget(varargin)
    end
    
    methods(Access=protected,Hidden)
        varargout = mycompatible(varargin)
        varargout = myparsetest(varargin)
        varargout = mysubsalt(varargin)
        specdisp(varargin)
    end
    
    methods (Access=protected,Hidden,Sealed)
        varargout = mybmatrix(varargin)
        varargout = mycovmatrix(varargin)
    end
    
end