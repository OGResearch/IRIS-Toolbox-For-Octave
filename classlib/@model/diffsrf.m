function [S,This] = diffsrf(This,Time,PList,varargin)
% diffsrf  Differentiate shock response functions w.r.t. specified parameters.
%
% Syntax
% =======
%
%     S = diffsrf(M,Range,PList,...)
%     S = diffsrf(M,NPer,PList,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose response functions will be simulated
% and differentiated.
%
% * `Range` [ numeric ] - Simulation date range with the first date being
% the shock date.
%
% * `NPer` [ numeric ] - Number of simulation periods.
%
% * `PList` [ char | cellstr ] - List of parameters w.r.t. which the
% shock response functions will be differentiated.
%
% Output arguments
% =================
%
% * `S` [ struct ] - Database with shock reponse derivatives stowed in
% multivariate time series.
%
% Options
% ========
%
% See [`model/srf`](model/srf) for options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Parse options.
opt = passvalopt('model.srf',varargin{:});

% Convert char list to cellstr.
if ischar(PList)
    PList = regexp(PList,'\w+','match');
end

%--------------------------------------------------------------------------

realexp = @(x) real(exp(x));
nAlt = size(This.Assign,3);

if nAlt > 1
    utils.error('model:diffsrf', ...
        ['Cannot run diffsrf() on ', ...
        'model objects with multiple parameterizations.']);
end

ix = strfun.findnames(This.name(This.nametype == 4),PList);
if any(isnan(ix))
    PList(isnan(ix)) = [];
    ix(isnan(ix)) = [];
end
ix = ix + sum(This.nametype < 4);

% Find optimal step for two-sided derivatives.
p = This.Assign(1,ix);
n = length(p);
h = eps^(1/3)*max([p;ones(size(p))],[],1);

% Assign alternative parameterisations p(i)+h(i) and p(i)-h(i).
This = alter(This,2*n);
P = struct();
twoSteps = nan(1,n);
for i = 1 : n
    pp = p(i)*ones(1,n);
    pp(i) = p(i) + h(i);
    pm = p(i)*ones(1,n);
    pm(i) = p(i) - h(i);
    P.(PList{i}) = [pp,pm];
    twoSteps(i) = pp(i) - pm(i);
end
This = assign(This,P);
This = solve(This);

% Simulate SRF for all parameterisations. Do not delog shock responses in
% `srf`; this will be done after differentiation.
opt0 = opt;
opt0.delog = false;
S = srf(This,Time,opt0);

% For each simulation, divide the difference from baseline by the size of
% the step.
for i = find(This.nametype <= 3)
    x = S.(This.name{i}).data;  
    c = S.(This.name{i}).Comment;
    dx = nan(size(x,1),size(x,2),n);
    for j = 1 : n
        dx(:,:,j) = (x(:,:,j) - x(:,:,n+j)) / twoSteps(j);
        c{1,:,j} = [c{1,:,j},'/',PList{j}];
    end
    if opt.delog && This.IxLog(i)
        dx = realexp(dx);
    end
    S.(This.name{i}).data = dx;
    S.(This.name{i}).Comment = c;
    S.(This.name{i}) = mytrim(S.(This.name{i}));
end

end