function [X,varargout] = unop(Func,X,Dim,varargin)
% unop  [Not a public function] Unary operators and functions on tseries objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if Dim == 0
    % Returns tseries of the same size.
    tmpSize = size(X.data);
    if ischar(Func)
        [X.data,varargout{1:nargout-1}] = ...
            feval(Func,X.data(:,:),varargin{:});
    else
        [X.data,varargout{1:nargout-1}] = Func(X.data(:,:),varargin{:});
    end
    if length(tmpSize) > 2
        X.data = reshape(X.data,[size(X.data,1),tmpSize(2:end)]);
    end
    if ~isempty(X.data) && any(any(isnan(X.data([1,end],:))))
        X = mytrim(X);
    end
elseif Dim == 1
    % Returns numeric array as a result of applying FUNC in 1st dimension
    % (time).
    if ischar(Func)
        [X,varargout{1:nargout-1}] = feval(Func,X.data,varargin{:});
    else
        [X,varargout{1:nargout-1}] = Func(X.data,varargin{:});
    end
else
    % Returns a tseries shrunk in DIM as a result of applying FUNC in that
    % dimension
    if ischar(Func)
        [X.data,varargout{1:nargout-1}] = feval(Func,X.data,varargin{:});
    else
        [X.data,varargout{1:nargout-1}] = Func(X.data,varargin{:});
    end
    Dim = size(X.data);
    X.Comment = cell([1,Dim(2:end)]);
    X.Comment(:) = {''};
    if ~isempty(X.data) && any(any(isnan(X.data([1,end],:))))
        X = mytrim(X);
    end
end



end
