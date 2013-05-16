function R = cov2corr(C,varargin)
% COV2CORR  [Not a public function] Autocovariance to autocorrelation function conversion.
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
realsmall = getrealsmall();
nAlt = size(R,4);
diagInx = eye(size(R,1)) == 1;

for iAlt = 1 : nAlt
    for i = 1 : size(R,3)
        Ri = C(:,:,i,iAlt);
        if i == 1 || ~isAcf
            stdinv = diag(Ri);
            nonzero = abs(stdinv) > realsmall;
            stdinv(nonzero) = 1./sqrt(stdinv(nonzero));
            D = stdinv * stdinv.';
        end
        index = ~isfinite(Ri);
        Ri(index) = 0;
        Ri = D .* Ri;
        Ri(index) = NaN;
        if i == 1 || ~isAcf
            Ri(diagInx) = 1;
        end
        R(:,:,i,iAlt) = Ri;
    end
end

end