function [Obj,RegOutp] = myfdlik(This,Inp,~,LikOpt)
% myfdlik  [Not a public function] Approximate likelihood function in frequency domain.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% TODO: Allow for non-stationary measurement variables.

%--------------------------------------------------------------------------

s = struct();
s.noutoflik = length(LikOpt.outoflik);
s.isObjOnly = narargout == 1;

nAlt = size(This.Assign,3);
ne = sum(This.nametype == 3);
realSmall = getrealsmall();

% Number of original periods.
[~,nPer,nData] = size(Inp);
freq = 2*pi*(0 : nPer-1)/nPer;

% Number of fundemantal frequencies.
N = 1 + floor(nPer/2);
freq = freq(1:N);

% Band of frequencies.
frqLo = 2*pi/max(LikOpt.band);
frqHi = 2*pi/min(LikOpt.band);
ixFrq = freq >= frqLo & freq <= frqHi;

% Drop zero frequency unless requested.
if ~LikOpt.zero
    ixFrq(freq == 0) = false;
end
ixFrq = find(ixFrq);

% Kronecker delta.
kr = ones(1,N);
if mod(nPer,2) == 0
    kr(2:end-1) = 2;
else
    kr(2:end) = 2;
end

nLoop = max(nAlt,nData);

% Pre-allocate output data.
Obj = nan(1,nLoop);
if ~s.isObjOnly
    RegOutp = struct();
    RegOutp.V = nan(1,nLoop,LikOpt.precision);
    RegOutp.Delta = nan(s.noutoflik,nLoop,LikOpt.precision);
    RegOutp.PDelta = nan(s.noutoflik,s.noutoflik,nLoop,LikOpt.precision);
end

for iLoop = 1 : nLoop
    
    % Next data
    %-----------
    % Measurement variables.
    y = Inp(1:ny,:,min(iLoop,end));
    % Exogenous variables in dtrend equations.
    g = Inp(ny+1:end,:,min(iLoop,end));
    excl = LikOpt.exclude(:) | any(isnan(y),2);
    nYIncl = sum(~excl);
    diagInx = logical(eye(nYIncl));
    
    if iLoop <= nAlt
        
        [T,R,K,Z,H,D,U,Omg] = mysspace(This,iLoop,false); %#ok<ASGLU>
        [nx,nb] = size(T);
        nf = nx - nb;
        nunit = mynunit(This,iLoop);
        % Z(1:nunit,:) assumed to be zeros.
        if any(any(abs(Z(:,1:nunit)) > realSmall))
            utils.error('model', ...
                ['Cannot evalutate likelihood in frequency domain ', ...
                'with non-stationary measurement variables.']);
        end
        T = T(nf+nunit+1:end,nunit+1:end);
        R = R(nf+nunit+1:end,1:ne);
        Z = Z(~excl,nunit+1:end);
        H = H(~excl,:);
        Sa = R*Omg*transpose(R);
        Sy = H(~excl,:)*Omg*H(~excl,:).';
        
        % Fourier transform of steady state.
        isSstate = false;
        if ~LikOpt.deviation
            id = find(This.nametype == 1);
            S = mytrendarray(This,id,1:nPer,false,iLoop);
            isSstate = any(S(:) ~= 0);
            if isSstate
                S = fft(S.').';
            end
        end
        
    end
        
    % Fourier transform of deterministic trends.
    isDtrends = false;
    if LikOpt.dtrends
        [D,M] = mydtrends4lik(This,LikOpt.ttrend,LikOpt.outoflik,g,iLoop);
        isDtrends = any(D(:) ~= 0);
        if isDtrends
            D = fft(D.').';
        end
        isOutOfLik = ~isempty(M) && any(M(:) ~= 0);
        if isOutOfLik
            M = permute(M,[3,1,2]);
            M = fft(M);
            M = ipermute(M,[3,1,2]);
        end
    end
        
    % Subtract sstate trends from observations; note that fft(y-s)
    % equals fft(y) - fft(s).
    if ~LikOpt.deviation && isSstate
        y = y - S;
    end
    
    % Subtract deterministic trends from observations.
    if LikOpt.dtrends && isDtrends
        y = y - D;
    end
    
    % Remove measurement variables excluded from likelihood by the user, or
    % those that have within-sample NaNs.
    y = y(~excl,:);
    y = y / sqrt(nPer);
    
    M = M(~excl,:,:);
    M = M / sqrt(nPer);
    
    L0 = 0;
    L1 = 0;
    L2 = 0;
    L3 = 0;
    nobs = 0;
    
    for i = ixFrq
        freqi = freq(i);
        deltai = kr(i);
        yi = yy(:,i);
        doOneFrequency();
    end
    
    [Obj(iLoop),V,Delta,PDelta] = ...
        kalman.oolik(L0,L1,L2,L3,nobs,LikOpt);
    
    if s.isObjOnly
        continue
    end
    
    RegOutp.V(1,iLoop) = V;
    RegOutp.Delta(:,iLoop) = Delta;
    RegOutp.PDelta(:,:,iLoop) = PDelta;
    
end

% Nested functions.

%**************************************************************************
    function doOneFrequency()
        nobs = nobs + deltai*nYIncl;
        ZiW = Z / ((eye(size(T)) - T*exp(-1i*freqi)));
        G = ZiW*Sa*ZiW' + Sy;
        G(diagInx) = real(G(diagInx));
        L0 = L0 + deltai*real(log(det(G)));
        L1 = L1 + deltai*real((y(:,i)'/G)*yi);
        if isOutOfLik
            MtGi = M(:,:,i)'/G;
            L2 = L2 + deltai*real(MtGi*M(:,:,i));
            L3 = L3 + deltai*real(MtGi*yi);
        end
    end % doOneFrequency().

end