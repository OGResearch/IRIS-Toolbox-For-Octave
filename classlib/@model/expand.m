function This = expand(This,K)
% expand  Compute forward expansion of model solution for anticipated shocks.
%
% Syntax
% =======
%
%     M = expand(M,K)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose solution will be expanded.
%
% * `K` [ numeric ] - Number of periods ahead, t+k, up to which the
% solution for anticipated shocks will be expanded.
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with the solution expanded.
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

ne = sum(This.nametype == 3);
nn = sum(This.nonlin);
nAlt = size(This.Assign,3);
if ne == 0 && nn == 0
    return
end

% Impact matrix of structural shocks.
R = This.solution{2};

% Impact matrix of non-linear add-factors.
Y = This.solution{8};

% Expansion up to t+k0 available.
k0 = size(R,2)/ne - 1;

% Expansion up to t+k0 already available.
if k0 >= K
    return
end

% Expand the R and Y solution matrices.
This.solution{2}(:,end+(1:ne*(K-k0)),1:nAlt) = NaN;
This.solution{8}(:,end+(1:nn*(K-k0)),1:nAlt) = NaN;
for iAlt = 1 : nAlt
    % m.Expand{5} Jk stores J^(k-1) and needs to be updated after each
    % expansion.
    [This.solution{2}(:,:,iAlt), ...
        This.solution{8}(:,:,iAlt), ...
        This.Expand{5}(:,:,iAlt)] = ...
        model.myexpand(R(:,:,iAlt),Y(:,:,iAlt),K, ...
        This.Expand{1}(:,:,iAlt),This.Expand{2}(:,:,iAlt),This.Expand{3}(:,:,iAlt), ...
        This.Expand{4}(:,:,iAlt),This.Expand{5}(:,:,iAlt),This.Expand{6}(:,:,iAlt));
end

end