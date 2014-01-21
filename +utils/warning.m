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

stack = utils.getstack();

msg = sprintf('<a href="">IRIS Toolbox Warning</a> @ %s.', ...
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

end % xxFrequents().