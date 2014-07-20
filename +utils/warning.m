function warning(Memo,Body,varargin)
% warning  [Not a public function] IRIS warning master file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

try %#ok<TRYNC>
    q = warning('query',['IRIS:',Memo]);
    if strcmp(q.state,'off')
        return
    end
end

stack = utils.getstack();

msg = mosw.sprintf('<a href="">IRIS Toolbox Warning</a> @ %s.',Memo);
msg = [msg,mosw.sprintf(['\n*** ',Body],varargin{:})];

msg = [msg,utils.displaystack(stack)];
state = warning('off','backtrace');
warning(['IRIS:',Memo],'%s',msg);
warning(state);

strfun.loosespace();

end
