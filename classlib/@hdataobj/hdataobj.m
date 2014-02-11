classdef hdataobj < handle
    
    properties
        data = [];
        Precision = 'double';
        IsPreSample = true;
        IsStd = false;
        IsParam = true;
        Contrib = '';
    end
    
    methods
        varargout = hdataassign(varargin)
        varargout = hdatainit(varargin)
        varargout = hdata2tseries(varargin)
    end
    
    methods (Static)
        varargout = hdatafinal(varargin)
    end
    
    % Constructor
    %-------------
    methods
        function This = hdataobj(varargin)
            if nargin == 0
                return
            end
            if nargin == 1 && isa(varargin{1},'hdataobj')
                This = varargin{1};
                return
            end
            if nargin > 1
                hdatainit(This,varargin{:});
            end
        end
    end
    
end