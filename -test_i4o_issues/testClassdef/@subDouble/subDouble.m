classdef subDouble < double

methods

  function this = subDouble(num,varargin)
      if nargin == 0
          num = [];
      end
      this = this@double(num);
  end
  
end


end