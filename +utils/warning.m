function warning(Memo,Body,varargin)
% warning  [Not a public function] IRIS warning master file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

try %#ok<TRYNC>
    q = warning('query',['iris:',Memo]);
    if strcmp(q.state,'off')
        return
    end
end

if ~isempty(Body) && Body(1) == '#'
    Body = xxFrequents(Body);
end

stack = utils.getstack();

msg = sprintf('<a href="">IRIS Toolbox Warning</a> :: %s.', ...
    (Memo));
if isempty(varargin)
    msg = [msg,sprintf('\n*** '),Body];
else
    msg = [msg,sprintf(['\n*** ',Body],varargin{:})];
end

msg = [msg,utils.displaystack(stack)];
state = warning('off','backtrace');
warning(['IRIS:',Memo],'%s',msg);
warning(state);

strfun.loosespace();

end

% Subfunctions.

%**************************************************************************
function Body = xxFrequents(Body)

switch Body
    case '#Solution_not_available'
        Body = 'Solution not available:%s.';
    otherwise
        Body = '';
end

end % xxFrequents().