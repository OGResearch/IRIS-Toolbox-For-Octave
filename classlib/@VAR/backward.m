function This = backward(This)
% backward  Backward VAR process.
%
% Syntax
% =======
%
%     B = backward(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% Output arguments
% =================
%
% * `B` [ VAR ] - VAR object with the VAR process reversed in time.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

isStationary = isstationary(This);
for iAlt = 1 : nAlt
    if isStationary(iAlt)
        [T,R,~,~,~,~,U,Omg] = sspace(This,iAlt);
        % 0th and 1st order autocovariance matrices of stacked y vector.
        C = covfun.acovf(T,R,[],[],[],[],U,Omg,This.eigval(1,:,iAlt),1);
        A = transpose(C(:,:,2)) / C(:,:,1);
        Q = A*C(:,:,2);
        Omg = C(:,:,1) + A*C(:,:,1)*transpose(A) - Q - transpose(Q);
        A = A(end-ny+1:end,:);
        A = reshape(A,[ny,ny,p]);
        A = A(:,:,end:-1:1);
        This.A(:,:,iAlt) = A(:,:);
        This.Omega(:,:,iAlt) = Omg(end-ny+1:end,end-ny+1:end);
        This.K(:,:,iAlt) = ...
            sum(poly.var2poly(This.A(:,:,iAlt)),3)*mean(This,iAlt);
    else
        % Non-stationary parameterisations.
        This.A(:,:,iAlt) = NaN;
        This.Omega(:,:,iAlt) = NaN;
        This.K(:,:,iAlt) = NaN;
    end
end

if any(~isStationary)
    utils.warning('VAR', ...
        ['Cannot compute backward VAR ', ...
        'for non-stationary parameterisations:%s.'], ...
        preparser.alt2str(~isStationary));
end

[This.T,This.U,This.eigval] = schur(This.A);

end
