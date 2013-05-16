function m = expand(m,k)
% expand  Compute forward expansion of model solution for anticipated shocks.
%
% Syntax
% =======
%
%     m = expand(m,k)
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object whose solution will be expanded.
%
% * `k` [ numeric ] - Number of periods ahead, t+k, up to which the
% solution for anticipated shocks will be expanded.
%
% Output arguments
% =================
%
% * `m` [ model ] - Model object with the solution expanded.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

ne = sum(m.nametype == 3);
nn = sum(m.nonlin);
nalt = size(m.Assign,3);
if ne == 0 && nn == 0
    return
end

% Impact matrix of structural shocks.
R = m.solution{2};

% Impact matrix of non-linear add-factors.
Y = m.solution{8};

% Expansion up to t+k0 available.
k0 = size(R,2)/ne - 1;

% Expansion up to t+k0 already available.
if k0 >= k
    return
end

% Exand the R and Y solution matrices.
m.solution{2}(:,end+(1:ne*(k-k0)),1:nalt) = NaN;
m.solution{8}(:,end+(1:nn*(k-k0)),1:nalt) = NaN;
for ialt = 1 : nalt
    % m.Expand{5} Jk stores J^(k-1) and needs to be updated after each
    % expansion.
    [m.solution{2}(:,:,ialt), ...
        m.solution{8}(:,:,ialt), ...
        m.Expand{5}(:,:,ialt)] = ...
        model.myexpand(R(:,:,ialt),Y(:,:,ialt),k, ...
        m.Expand{1}(:,:,ialt),m.Expand{2}(:,:,ialt),m.Expand{3}(:,:,ialt), ...
        m.Expand{4}(:,:,ialt),m.Expand{5}(:,:,ialt),m.Expand{6}(:,:,ialt));
end

end