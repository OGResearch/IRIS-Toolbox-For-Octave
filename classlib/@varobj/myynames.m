function varargout = myynames(This,YNames)
% myynames [Not a public function] Get or set names of varobj variables.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

%--------------------------------------------------------------------------

try
    YNames; 
catch
    varargout{1} = This.YNames;
    return
end

ny = myny(This);

if isempty(YNames)
    YNames = @(n) sprintf('y%g',n);
elseif ischar(YNames)
    YNames = regexp(YNames,'\w+','match');
elseif ~iscellstr(YNames) ...
        && (~isa(YNames,'function_handle') || ny == 0)
    utils.error('VAR', ...
        'Invalid type of input for variable names.');
end

if ny > 0 && iscellstr(YNames) && ny ~= length(YNames)
    utils.error('VAR', ...
        'Incorrect number of variable names supplied.');
end

if iscellstr(YNames)
    This.YNames = YNames(:).';
elseif isa(YNames,'function_handle') && ny > 0
    This.YNames = cell(1,ny);
    for i = 1 : ny
        This.YNames{i} = YNames(i);
    end
end

if unique(length(This.YNames)) ~= length(This.YNames)
    utils.error('VAR', ...
        'Variable names must be unique.');
end

varargout{1} = This;

end