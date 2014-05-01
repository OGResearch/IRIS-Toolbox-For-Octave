function [s,m] = diffsrf(m,time,plist,varargin)
% diffsrf  Differentiate shock response functions w.r.t. specified parameters.
%
% Syntax
% =======
%
%     S = diffsrf(M,RANGE,LIST,...)
%     S = diffsrf(M,NPER,LIST,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose response functions will be simulated
% and differentiated.
%
% * `RANGE` [ numeric ] - Simulation date range with the first date being
% the shock date.
%
% * `NPER` [ numeric ] - Number of simulation periods.
%
% * `LIST` [ char | cellstr ] - List of parameters w.r.t. which the
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
options = passvalopt('model.srf',varargin{:});

% Convert char list to cellstr.
if ischar(plist)
    plist = regexp(plist,'\w+','match');
end

%**************************************************************************

nalt = size(m.Assign,3);

if nalt > 1
    utils.error('model', ...
        ['The function DIFFSRF can be used only with ', ...
        'single-parameterisation models.']);
end

index = strfun.findnames(m.name(m.nametype == 4),plist);
if any(isnan(index))
    plist(isnan(index)) = [];
    index(isnan(index)) = [];
end
index = index + sum(m.nametype < 4);

% Find optimal step for two-sided derivatives.
p = m.Assign(1,index);
n = length(p);
h = eps^(1/3)*max([p;ones(size(p))],[],1);

% Assign alternative parameterisations p(i)+h(i) and p(i)-h(i).
m = alter(m,2*n);
P = struct();
twoSteps = nan([1,n]);
for i = 1 : n
    pp = p(i)*ones([1,n]);
    pp(i) = p(i) + h(i);
    pm = p(i)*ones([1,n]);
    pm(i) = p(i) - h(i);
    P.(plist{i}) = [pp,pm];
    twoSteps(i) = pp(i) - pm(i);
end
m = assign(m,P);
m = solve(m);

% Simulate SRF for all parameterisations. Do not delogarithmise the shock
% responses in `srf`; this will be done at the end of this file, after
% differentiation.
optionslog = options.log;
options.log = false;
s = srf(m,time,options);

% For each simulation, divide the difference from baseline by the size of
% the step.
for i = find(m.nametype <= 3)
    x = s.(m.name{i}).data;
    c = s.(m.name{i}).Comment;
    dx = nan([size(x,1),size(x,2),n]);
    for j = 1 : n
        dx(:,:,j) = (x(:,:,j) - x(:,:,n+j)) / twoSteps(j);
        if ismatlab
            c(1,:,j) = regexprep(c(1,:,j),'.*',['$0/',plist{j}]);
        else
            c(1,:,j) = strcat(c(1,:,j),'/',plist{j});
        end
    end
    if optionslog && m.log(i)
        dx = exp(dx);
    end
    s.(m.name{i}).data = dx;
    s.(m.name{i}).Comment = c;
    s.(m.name{i}) = mytrim(s.(m.name{i}));
end

end