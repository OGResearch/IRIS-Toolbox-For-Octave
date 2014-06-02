classdef getsetobj
    % getsetobj  [Not a public class] Helper class to handle get and set requests.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2014 IRIS Solutions Team.
    
    properties
    end
    
    methods
        function This = getsetobj(varargin)
        end
    end
    
    methods
        varargout = get(varargin)
    end
    
    methods (Access=protected,Hidden)
        varargout = mystruct2obj(varargin)
    end
    
    methods (Static,Hidden)
        function Query = myalias(Query)
        end
    end

end