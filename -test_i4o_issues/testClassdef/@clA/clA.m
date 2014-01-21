classdef clA

    methods
        function this = clA(varargin)
            this = [1 2 3];
        end
    end


    methods (Hidden)
        function index = end (this,k,n)
            index = size(this,k);
        end
    end
end
