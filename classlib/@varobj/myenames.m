function varargout = myenames(This,varargin)
% myenames  [Not a public function] Get or set names of varobj residuals.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

if isempty(varargin)
    varargout{1} = This.Enames;
    return
end

%--------------------------------------------------------------------------

ENames = varargin{1};

ny = size(This.A,1);
if ny == 0 && ~isempty(This.Ynames)
    ny = length(This.Ynames);
end

if ny == 0
    utils.error('varobj', ...
        'Cannot set the names of residuals before the names of variables.');
end

if isempty(ENames)
    ENames = @(yname,n) sprintf('res_%s',yname);
elseif ischar(ENames)
    ENames = regexp(ENames,'\w+','match');
elseif iscellstr(ENames)
    %
elseif isa(ENames,'function_handle') && ~isempty(This.Ynames)
    %
else
    utils.error('VAR', ...
        'Invalid type of input for VAR residual names.');
end

if ny > 0 && iscellstr(ENames) && ny ~= length(ENames)
    utils.error('VAR', ...
        'Incorret number of residual names supplied.');
end

if iscellstr(ENames)
    This.Enames = ENames(:).';
elseif ~isempty(This.Ynames) && isa(ENames,'function_handle')
    This.Enames = cell(1,ny);
    for i = 1 : ny
        This.Enames{i} = ENames(This.Ynames{i},i);
    end
else
    This.Enames = cell(1,0);
end

if unique(length(This.Enames)) ~= length(This.Enames)
    utils.error('VAR', ...
        'Residual names must be unique.');
end

varargout{1} = This;

end