classdef chld1 < tpkg2.parnt
    
    methods
        function this = chld1(varargin)
            this.prop = [this.prop ' chld1'];
        end
        
        function callerMeth(this,varargin)
            trickyMeth(varargin{1})
            trickyMeth(this)
        end
    end
    
end