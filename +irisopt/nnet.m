function Def = nnet()
% optim  [Not a public function] Default options for nnet package.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def = struct();

validTransferFn = @(x) any(strcmpi(x,{'sigmoid','linear','step','tanh'})) ;

Def.nnet = { ...
    'HiddenTransfer', 'sigmoid', @(x) iscellstr(x) || validTransferFn(x), ...
    'InputTransfer', 'sigmoid', validTransferFn, ...
    'OutputTransfer', 'sigmoid', validTransferFn, ...
    'Type', 'feedforward', @(x) any(strcmpi(x,{'feedforward'})), ...
    } ;

Def.estimate = { ...
    'optimset',{},@(x) isempty(x) || isstruct(x) || (iscell(x) && iscellstr(x(1:2:end))), ...
    'solver,optimiser,optimizer','fmin',@(x) (ischar(x) && isanychari(x,{'fmin','lsqnonlin','pso'})), ...
    } ;

end


