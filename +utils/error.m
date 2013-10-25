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

%{
% Get the stack of callers and remove; we remove all backend IRIS function
% from it.
stack = dbstack('-completenames');

% Get the IRIS root directory name.
[ans,irisfolder] = fileparts(irisget('irisroot')); %#ok<NOANS,ASGLU>
% Exclude functions contained in the IRIS root directory.
omit = 0;
nStack = length(stack);
while omit < nStack ...
        && ~isempty(strfind(stack(omit+1).file,irisfolder))
    omit = omit + 1;
end

% Remove all backend IRIS functions from the stack and throw the error with
% the remaining callers only.
stack(1:omit-1) = [];
%}

stack = utils.getstack();

% Throw an error with stack of non-IRIS function calls.
if isempty(stack)
    stack = struct('file','','name','','line',NaN);
end

msg = sprintf('IRIS Toolbox Error :: %s.',(Mnemonic));
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


% Subfunctions.


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
end % xxFrequents().
