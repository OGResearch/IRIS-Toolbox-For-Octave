function varargout = get(This,varargin)
% get  [Not a public function] Backend function for GET methods.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

varargout = cell(size(varargin));
varargin = strtrim(varargin);
nArg = length(varargin);
flag = true(1,nArg);

for iArg = 1 : nArg
    func = [];
    query = strtrim(lower(varargin{iArg}));
    if ~isempty(query) && query(end) == '='
        query(end) = '';
    end
    tokens = regexp(query,'^(\w+)\((\w+)\)$','once','tokens');
    if ~isempty(tokens) && ~isempty(tokens{1})
        func = tokens{1};
        query = tokens{2};
    end
    
    % Replace alternate names with the standard ones.
    query = This.myalias(query);
    
    % Remove black spaces.
    query = regexprep(query,'\s+','');
    
    % Call class specific get methods, `specget`.
    [varargout{iArg},flag(iArg)] = specget(This,query);
    
    if ~isempty(func)
        varargout{iArg} = feval(func,varargout{iArg});
    end
end

% Report invalid queries.
if any(~flag)
    utils.error(class(This), ...
        'This is not valid query to %s object: ''%s''.', ...
        class(This),varargin{~flag});
end

end