function varargout = error(Mnemonic,Body,varargin)
% error  [Not a public function] IRIS error master file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ~isempty(Body) && Body(1) == '#'
    Body = xxFrequents(Body);
end

% Throw an error with stack of non-IRIS function calls.
stack = utils.getstack();
if isempty(stack)
    stack = struct('file','','name','command prompt.','line',NaN);
end

msg = sprintf('IRIS Toolbox Error @ %s.',(Mnemonic));
if isempty(varargin)
    msg = [msg,sprintf('\n*** '),Body];
else
    msg = [msg,sprintf(['\n*** ',Body],varargin{:})];
end

if nargout == 0
    tmp = struct();
    tmp.message = msg;
    tmp.identifier = ['IRIS:',Mnemonic];
    tmp.stack = stack;
    error(tmp);
else
    varargout{1} = msg;
end

end


% Subfunctions...


%**************************************************************************
function Body = xxFrequents(Body)
switch Body
    case '#Name_not_exists'
        Body = 'This name does not exist in the model object: %s.';
    case '#Cannot_simulate_contributions'
        Body = ['Cannot simulate multiple parameterisations ', ...
            'or multiple data sets ', ...
            'with ''contributions='' true'];
    otherwise
        Body = '';
end
end % xxFrequents()
