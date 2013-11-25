classdef estimateobj
    % estimateobj  [Not a public class] Estimation superclass.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.
    
    properties
    end
    
    methods
        varargout = neighbourhood(varargin)
    end

    methods (Abstract)
        varargout = objfunc(varargin)
    end
    
    methods (Access=protected,Hidden)
        varargout = mydiffprior(varargin)
        varargout = myparamstruct(varargin)
    end

    methods (Access=protected,Hidden,Static)
        varargout = myevalpprior(varargin)
    end
    
end