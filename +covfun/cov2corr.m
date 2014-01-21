function R = cov2corr(C,varargin)
% cov2corr  [Not a public function] Autocovariance to autocorrelation function conversion.
%
% Syntax
% =======
%
%     R = covfun.cov2corr(C)
%     R = covfun.cov2corr(C,'acf')
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% If called from within `acf` functions, std errors will be taken from
% the first page of each parameterisation. Otherwise, std errors will
% be updated for each individual matrix.
isAcf = any(strcmpi(varargin,'acf'));

%--------------------------------------------------------------------------

R = C;
realSmall = getrealsmall();
nAlt = size(R,4);
diagInx = eye(size(R,1)) == 1;

for iAlt = 1 : nAlt
    for i = 1 : size(R,3)
        Ri = C(:,:,i,iAlt);
        if i == 1 || ~isAcf
            stdInv = diag(Ri);
            nonZero = abs(stdInv) > realSmall;
            stdInv(nonZero) = 1./sqrt(stdInv(nonZero));
            D = stdInv * stdInv.';
        end
        inx = ~isfinite(Ri);
        Ri(inx) = 0;
        Ri = D .* Ri;
        Ri(inx) = NaN;
        if i == 1 || ~isAcf
            Ri(diagInx) = 1;
        end
        R(:,:,i,iAlt) = Ri;
    end
end

end