classdef dbcollect
   
    properties
        Container = {};
        Legend = {};
        Error = true;
        Catch = [];
        AggregationFunc = @horzcat;
    end

    methods
        varargout = container(varargin)
        varargout = error(varargin)
        varargout = fieldnames(varargin)
        varargout = legend(varargin)
        varargout = subsref(varargin)
    end
    
    methods
        function This = dbcollect(varargin)
            if isempty(varargin)
                return
            end
            structInx = cellfun(@isstruct,varargin);
            charInx = cellfun(@ischar,varargin);
            This.Container = varargin(structInx);
            n = length(This.Container);
            This.Legend = varargin(charInx);
            if length(This.Legend) < n
                This.Legend(end+1:n) = {''};
            elseif length(This.Legend) > n
                This.Legend = This.Legend(1:n);
            end
            This.Legend = regexprep(This.Legend,'=$','');
        end
    end
    
end