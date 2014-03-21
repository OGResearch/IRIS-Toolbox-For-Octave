classdef clA
  
  properties
    data = [];
  end
  
  properties (GetAccess=public,SetAccess=protected,Hidden)
    dataProt = [];
  end
  
  methods
    function this = clA(varargin)
      this.data = [1 2 3];
      this.dataProt = [];
    end
    function varargout = subsref(this,s)
      switch s.type
        case {'{}','()'}
          varargout{1} = builtin('subsref',this.data,s);
        otherwise
          varargout{1} = builtin('subsref',this,s);
      end
    end
    function this = subsasgn(this,s,y)
      switch s.type
        case {'{}','()'}
          this = builtin('subsasgn',this.data,s,y);
        otherwise
          this = builtin('subsasgn',this,s,y);
          %this.dataProt = y;
      end
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
