classdef clA
  
  properties
    data = [];
  end
  
  methods
    function this = clA(varargin)
      this.data = [1 2 3];
    end
    function varargout = subsref(this,s)
      varargout{1} = builtin('subsref',this.data,s);
    end
    function disp(this)
      disp(this.data)
    end
  end
    
  methods (Hidden)
    function index = end(this,k,n)
      if n==1
        index = numel(this.data);
      else
        index = size(this.data,k);
      end
    end
  end
end
