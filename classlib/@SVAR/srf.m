function [S,C,S1,C1] = srf(This,Time,varargin)
% srf  Shock (impulse) response function.
%
% Syntax
% =======
%
%     [R,Cum] = srf(V,NPer)
%     [R,Cum] = srf(V,Range)
%
% Input arguments
% ================
%
% * `V` [ SVAR ] - SVAR object for which the impulse response function will
% be computed.
%
% * `NPer` [ numeric ] - Number of periods.
%
% * `Range` [ numeric ] - Date range.
%
% Output arguments
% =================
%
% * `R` [ tseries | struct ] - Shock response functions.
%
% * `Cum` [ tseries | struct ] - Cumulative shock response functions.
%
% Options
% ========
%
% * `'presample='` [ `true` | *`false`* ] - Include zeros for pre-sample
% initial conditions in the output data.
%
% * `'select='` [ cellstr | char | logical | numeric | *`Inf`* ] - Selection
% of shocks to which the responses will be simulated.
%
% Description
% ============
%
% For backward compatibility, the following calls into the `srf` function is
% also possible:
%
%     [~,~,s,c] = srf(this,nper)
%     [~,~,s,c] = srf(this,range)
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

opt = passvalopt('SVAR.srf',varargin{:});

% Tell if `time` is `nper` or `range`.
if length(Time) == 1 && round(Time) == Time && Time > 0
    range = 1 : Time;
else
    range = Time(1) : Time(end);
end
nPer = length(range);

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

select = utils.nameselection(ny,This.Enames,opt.select);
ne = sum(select);

% Compute VMA matrices.
A = This.A;
B = This.B;
Phi = timedom.var2vma(A,B,nPer,select);

% Create shock paths.
Eps = zeros(ny,ne,nPer,nAlt);
for iAlt = 1 : nAlt
    E = eye(ny);
    E = E(:,select);
    Eps(:,:,1,iAlt) = E;
end

% Permute dimensions so that time runs along the 2nd dimension.
Phi = permute(Phi,[1,3,2,4]);
Eps = permute(Eps,[1,3,2,4]);

% Add a total of `p` zero initial conditions.
if opt.presample
    Phi = [zeros(ny,p,ne,nAlt),Phi];
    Eps = [nan(ny,p,ne,nAlt),Eps];
    xrange = range(1)-p : range(end);
else
    xrange = range;
end

S = myoutpdata(This,'auto',xrange, ...
    [Phi;Eps],[],[This.Ynames,This.Enames]);
% For bkw compatibility.
if nargout > 2
    S1 = myoutpdata(This,'tseries',xrange, ...
        [Phi;Eps],[],[This.Ynames,This.Enames]);
end

if nargout > 1
    Psi = cumsum(Phi,2);
    C = myoutpdata(This,'auto',xrange, ...
        [Psi;Eps],[],[This.Ynames,This.Enames]);
    % For bkw compatibility.
    if nargout > 3
        C1 = myoutpdata(This,'tseries',xrange, ...
            [Psi;Eps],[],[This.Ynames,This.Enames]);
    end
end

end