function [Stat,Crit] = portest(This,Inp,H,varargin)
% portest  Portmanteau test for autocorrelation in VAR residuals.
%
% Syntax
% =======
%
%     [Stat,Crit] = portest(V,Data,H)
%
% Input arguments
% ================
%
% * `V` [ VAR | swar ] - Estimated VAR from which the tested residuals were
% obtained.
%
% * `Data` [ tseries ] - VAR residuals, or VAR output data including
% residuals, to be tested for autocorrelation.
%
% * `H` [ numeric ] - Test horizon; must be greater than the order of the
% tested VAR.
%
% Output arguments
% =================
%
% * `Stat` [ numeric ] - Portmanteau test statistic.
%
% * `Crit` [ numeric ] - Portmanteau test critical value based on
% chi-square distribution.
%
% Options
% ========
%
% * `'level='` [ numeric | *`0.05`* ] - Requested significance level for
% computing the criterion `Crit`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

pp = inputParser();
if ismatlab
pp.addRequired('V',@(x) isa(x,'VAR'));
pp.addRequired('Inp',@(x) myisvalidinpdata(This,x));
pp.addRequired('H',@isnumericscalar);
pp.parse(This,Inp,H);
else
pp = pp.addRequired('V',@(x) isa(x,'VAR'));
pp = pp.addRequired('Inp',@(x) myisvalidinpdata(This,x));
pp = pp.addRequired('H',@isnumericscalar);
pp = pp.parse(This,Inp,H);
end

if length(varargin) == 1 && isnumericscalar(varargin{1})
    % Bkw compatibility.
    varargin = [{'level='},varargin];
end

opt = passvalopt('VAR.portest',varargin{:});

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

if H <= p
    utils.error('VAR', ...
        'Order of Portmonteau test must be higher than VAR order.');
end

% Request residuals.
[~,~,~,e] = mydatarequest(This,Inp,This.range);
nData = size(e,3);
if nData ~= nAlt
    utils.error('VAR', ...
        'Number of parameterisations and number of data sets must match.');
end

% Orthonormalise residuals by Choleski factor of Omega.
for iAlt = 1 : nAlt
    P = chol(This.Omega(:,:,iAlt));
    e(:,:,iAlt) = P\e(:,:,iAlt);
end

% Test statistic.
Stat = zeros(1,nAlt);
for iAlt = 1 : nAlt
    fitted = This.fitted(1,:,iAlt);
    nObs = sum(fitted);
    ei = e(:,fitted,iAlt);
    for i = 1 : H
        Ci = ei(:,1+i:end)*ei(:,1:end-i)' / nObs;
        Stat(iAlt) = Stat(iAlt) + trace(Ci'*Ci) / (nObs-i);
    end
    Stat(iAlt) = (nObs^2) * Stat(iAlt);
end

% Critical value.
if nargout > 1
    Crit = chi2inv(1-opt.level,ny^2*(H-p));
end

end