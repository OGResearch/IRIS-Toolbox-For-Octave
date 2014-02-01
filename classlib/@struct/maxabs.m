function x = maxabs(x,varargin)

if ~isempty(varargin)
    x = dbfun(@maxabs,x,varargin{1});
else
    x = dbfun(@maxabs,x);
end

end