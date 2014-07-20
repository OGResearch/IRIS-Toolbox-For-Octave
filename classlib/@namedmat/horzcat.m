function varargout = horzcat(varargin)

for i = 1 : length(varargin)
    if isnamedmat(varargin{i})
        varargin{i} = double(varargin{i});
    end
end

[varargout{1:nargout}] = horzcat(varargin{:});

end
