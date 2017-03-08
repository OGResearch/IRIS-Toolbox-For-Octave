classdef parnt < handle
    
    properties
        prop = '';
    end
    
    methods
        function this = parnt(varargin)
            this.prop = [this.prop ' parnt'];
        end
    end
    
    methods (Access = protected, Hidden)
        function trickyMeth(this)
           disp('trickyMeth@tpkg2.parnt');
        end
    end
end