classdef trec
    
    
    properties
        Dates = [];
        Shift = 0;
    end

    
    methods
        function This = trec(varargin)
            if isempty(varargin)
                return
            end
            if length(varargin) == 1 && isa(varargin{1},'trec')
                This = varargin{1};
                return
            end
            if length(varargin) == 1 && isnumeric(varargin{1})
                This.Dates = varargin{1};
                return
            end
        end
    end
    
    
    methods
        function This = plus(This,K)
            This.Shift = This.Shift + K;
        end
        function This = minus(This,K)
            This.Shift = This.Shift - K;
        end
        function This = set.Dates(This,X)
            if any(~freqcmp(X))
                utils.error('trec:Range', ...
                    ['Multiple frequencies not allowed in date vectors ', ...
                    'in time-recursive expressions.']);
            end
            This.Dates = X;
        end
        function This = set.Shift(This,X)
            if ~isintscalar(X)
                utils.error('trec:Shift', ...
                    ['Lags and leads must be integer scalars ', ...
                    'in time-recursive expressions.']);
            end
            This.Shift = X;
        end
    end
    
end
