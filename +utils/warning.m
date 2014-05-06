function warning(Memo,Body,varargin)
% warning  [Not a public function] IRIS warning master file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ~ismatlab
    Body = regexprep(Body,'matlab','Octave','ignorecase');
end

try %#ok<TRYNC>
    q = warning('query',['iris:',Memo]);
    if strcmp(q.state,'off')
        return
    end
end

stack = utils.getstack();

if ismatlab
    msg = sprintf('<a href="">IRIS Toolbox Warning</a> @ %s.', ...
        (Memo));
else
    msg = sprintf('IRIS Toolbox Warning @ %s.', ...
        (Memo));
end
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