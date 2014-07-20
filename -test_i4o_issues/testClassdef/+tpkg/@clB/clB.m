classdef clB < handle
    
    properties
        prop1 = '';
        prop2 = '';
    end
    
    properties (Dependent)
        dprop1
        dprop2
    end
    
    methods
        
        function This = clB(varargin)
            This.prop1 = 'ahoj';
            This.prop2 = 'privet';
        end
        
        function DepProp1 = get.dprop1(This)
            DepProp1 = This.prop2;
        end
        
        function DepProp2 = get.dprop2(This)
            DepProp2 = This.prop1;
        end
        
        function This = set.dprop1(This,val)
            This.prop2 = val;
        end
        
        function This = set.dprop2(This,val)
            This.prop1 = val;
        end
    
        function showDepProp(This)
            showDepPropProt(This);
        end
        
    end
    
    methods (Access=protected,Hidden)
    
        function showDepPropProt(This)
            disp('u r in clB!');
        end
    
    end
    
end
