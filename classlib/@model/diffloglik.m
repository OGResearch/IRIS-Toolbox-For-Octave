function [MinusLogLik,Grad,Hess,V] ...
    = diffloglik(This,Data,Range,PList,varargin)
% diffloglik  Approximate gradient and hessian of log-likelihood function.
%
% Syntax
% =======
%
%     [MinusLogLik,Grad,Hess,V] = diffloglik(M,D,Range,PList,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose likelihood function will be
% differentiated.
%
% * `D` [ cell | struct ] - Input data from which measurement variables
% will be taken.
%
% * `Range` [ numeric ] - Date range on which the likelihood function
% will be evaluated.
%
% * `List` [ cellstr ] - List of model parameters with respect to which the
% likelihood function will be differentiated.
%
% Output arguments
% =================
%
% * `MinusLogLik` [ numeric ] - Value of minus the likelihood function at the input
% data.
%
% * `Grad` [ numeric ] - Gradient (or score) vector.
%
% * `Hess` [ numeric ] - Hessian (or information) matrix.
%
% * `V` [ numeric ] - Estimated variance scale factor if the `'relative='`
% options is true; otherwise `v` is 1.
%
% Options
% ========
%
% * `'chkSstate='` [ `true` | *`false`* | cell ] - Check steady state in
% each iteration; works only in non-linear models.
%
% * `'refresh='` [ *`true`* | `false` ] - Refresh dynamic links for each change
% in a parameter.
%
% * `'solve='` [ *`true`* | `false` | cellstr ] - Re-compute solution for
% each parameter change; you can specify a cell array with options for the
% `solve` function.
%
% * `'sstate='` [ `true` | *`false`* | cell ] - Re-compute steady state in each
% differentiation step; if the model is non-linear, you can pass in a cell
% array with options used in the `sstate` function.
%
% See help on [`model/filter`](model/filter) for other options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('model',@is.model);
pp.addRequired('data',@(x) isstruct(x) || iscell(x));
pp.addRequired('range',@isnumeric);
pp.addRequired('plist',@(x) ischar(x) || iscellstr(x));
pp.parse(This,Data,Range,PList);

[opt,varargin] = passvalopt('model.diffloglik',varargin{:});

% Process Kalman filter options; `loglikopt` also expands solution forward
% if needed for tunes on the mean of shocks.
lik = mypreploglik(This,Range,'t',[],varargin{:});

% Get measurement and exogenous variables including pre-sample.
Data = datarequest('yg*',This,Data,Range);

% Create an `stdcorr` vector from user-supplied database.
lik.stdcorr = mytune2stdcorr(This,Range,[],lik,'clip');

% Requested output data.
lik.retpevec = true;
lik.retf = true;

if ischar(PList)
    PList = regexp(PList,'\w+','match');
end

%--------------------------------------------------------------------------

nalt = size(This.Assign,3);

% Multiple parameterizations are not allowed.
if nalt > 1
    utils.error('model', ...
        'Cannot run DIFFLOGLIK on multiple parametrisations.');
end

% Find parameter names and create parameter index.
[assignpos,stdcorrpos] = mynameposition(This,PList,'error');

pri = struct();
pri.assignpos = assignpos;
pri.stdcorrpos = stdcorrpos;
pri.Assign = This.Assign;
pri.stdcorr = This.stdcorr;

% Call low-level diffloglik.
[MinusLogLik,Grad,Hess,V] = mydiffloglik(This,Data,pri,lik,opt);

end