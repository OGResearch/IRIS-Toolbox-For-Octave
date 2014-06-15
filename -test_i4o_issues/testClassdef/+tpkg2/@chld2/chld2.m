classdef chld2 < tpkg2.parnt
    
    methods
        function this = chld2(varargin)
            this.prop =  [this.prop ' chld2'];
        end
    end
    
    methods (Access = protected, Hidden)
        function trickyMeth(this)
           disp('trickyMeth@tpkg2.chld2');
        end
    end
    
end