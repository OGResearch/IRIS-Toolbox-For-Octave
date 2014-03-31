classdef subDouble < double

methods

  function this = subDouble(varargin)
    this = this@double(varargin);
    this = 'n';
  end
  
end


end