function varargout ...
    = failed(This,SstateOk,ChkSstateOk,SstateErrorList, ...
    NPath,NanDeriv,Sing2)
% failed  Give access to the last failed model object.
%
% Syntax
% =======
%
%     M = model.failed()
%
% Output arguments
% =================
%
% * `M` [ numeric ] - The model object with the parameterisation that
% failed to converge on steady state or to solve during one of the
% following functions: [`model/estimate`](model/estimate),
% [`model/diffloglik`](model/diffloglik), [`model/fisher`](model/fisher).
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% TODO: Write a separate function to produce the core of the message and
% share it with `model/solve`.

persistent STORE;

if nargin == 0
    varargout{1} = STORE;
    return
end

STORE = This;

if ~SstateOk
    c = utils.error('model', ...
        'Steady state failed to converge on current parameters.');
elseif ~ChkSstateOk
    c = utils.error('model', ...
        'Steady-state error in this equation: ''%s''.', ...
        SstateErrorList{:});
else
    [body,args] = mysolvefail(This,NPath,NanDeriv,Sing2);
    c = utils.error('model',body,args{:});
end

utils.error('model',[...
    'The model failed to updated new parameters.',...
    '\n\n', ...
    'Type <a href="matlab: x = model.failed();">', ...
    'x = model.failed();', ...
    '</a> to get the model object that failed to solve.',...
    '\n\n',c, ...
    ],'');

end