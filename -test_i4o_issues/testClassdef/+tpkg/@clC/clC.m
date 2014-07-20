classdef clC < tpkg.clB
    
    properties
        prop3 = [];
    end
    
    methods
    
        function This = clC(varargin)
            This.prop2 = 'joha';
            This.prop3 = 123;
        end
    
        function callMe(This,varargin)
            showDepProp(This);
        end
    
    end
    
    methods (Access=protected,Hidden)
    
        function showDepPropProt(This)
            fprintf('\tdprop1 = %s\n', This.dprop1);
            fprintf('\tdprop2 = %s\n', This.dprop2);
        end
    
    end
    
end
