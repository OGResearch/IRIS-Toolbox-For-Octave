classdef getsetobj
    % getsetobj  [Not a public class] Helper class to handle get and set requests.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.
    
%    properties % empty properties block is not allowed in Octave
%    end
    
    methods
        function This = getsetobj(varargin)
        end
    end
    %{
    methods
        function varargout = get(This,varargin)
          varargout = get_4oct(varargin)
        end
    end
    %}
    methods (Static,Hidden)
        function Query = myalias(Query)
        end
    end

end