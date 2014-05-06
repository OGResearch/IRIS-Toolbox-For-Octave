function This = assign(This,A,K,Omg,Fitted)
% assign  Manually assign system matrices to VAR object.
%
% Syntax
% =======
% 
%     V = assign(V,A,K,Omg)
%     V = assign(V,A,[],Omg)
%     V = assign(V,A,K,Omg,Dates)
%     V = assign(V,A,[],Omg,Dates)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object with variable names.
%
% * `A` [ numeric ] - Transition matrices; see Description.
%
% * `K` [ numeric | empty ] - Constant vector or matrix; if omitted, the
% constant vector will be set to zeros, and will not be included in the
% number of free parameters.
%
% * `Omg` [ numeric ] - Covariance matrix of forecast errors (reduced-form
% residuals).
%
% * `Dates` [ numeric ] - Vector of dates of (hypothetical) fitted
% observations; may be omitted.
%
% Output arguments
% =================
%
% * `V` [ VAR ] - VAR object with system matrices assigned.
%
% Description
% ============
%
% To assign matrices for a p-th order VAR, stack the transition
% matrices for individual lags horizontally, 
%
%     A = [A1,...,Ap]
%
% where `A1` is the coefficient matrix on the first lag, and `Ap` is the
% coefficient matrix on the last, p-th, lag.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    if isnumeric(Fitted)
        Fitted = {Fitted(:).'};
    end
    x = [Fitted{:}];
    xRange = min(x) : max(x);
catch
    Fitted = {};
    xRange = zeros(1,0);
end

%--------------------------------------------------------------------------

A = A(:,:,:);

ny = length(This.YNames);
nGrp = max(1,length(This.GroupNames));
nAlt = size(A,3);
nXPer = length(xRange);
ng = 0;
p = size(A,2) / ny;
nFree = p*ny*ny;

This = myprealloc(This,ny,p,nXPer,nAlt,nGrp,ng);
This = assign@varobj(This,A,Omg,xRange,Fitted);

if isempty(K)
    This.K = zeros(ny,nGrp,nAlt);
elseif size(K,1) ~= ny || (nGrp > 0 && size(K,2) ~= nGrp) ...
        || size(K,3) ~= nAlt
    utils.error('varobj:assign', ...
        'Invalid size of the constant matrix K.');
else
    This.K = K;
    nFree = nFree + ny;
end

This.G = zeros(ny,0);
This.Zi = zeros(0,ny*p+1);
This.NHyper = nFree;

This = schur(This);
This = infocrit(This);

end