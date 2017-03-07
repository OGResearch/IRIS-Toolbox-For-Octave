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
s.isObjOnly = nargout == 1;

nAlt = size(This.Assign,3);
ny = sum(This.nametype == 1);
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
nFrq = length(ixFrq);

% Kronecker delta.
kr = ones(1,N);
if mod(nPer,2) == 0
    kr(2:end-1) = 2;
else
    kr(2:end) = 2;
end

nLoop = max(nAlt,nData);

% Pre-allocate output data.
nObj = 1;
if LikOpt.objdecomp
    nObj = nFrq + 1;
end
Obj = nan(nObj,nLoop);

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
            isDelog = false;
            S = mytrendarray(This,iLoop,isDelog,id,1:nPer);
            isSstate = any(S(:) ~= 0);
            if isSstate
                S = S.';
                S = fft(S);
                S = S.';
            end
        end
        
    end
        
    % Fourier transform of deterministic trends.
    isDtrends = false;
    nOutOfLik = 0;
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
        nOutOfLik = size(M,2);
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
    
    L0 = zeros(1,nFrq+1);
    L1 = zeros(1,nFrq+1);
    L2 = zeros(nOutOfLik,nOutOfLik,nFrq+1);
    L3 = zeros(nOutOfLik,nFrq+1);
    nObs = zeros(1,nFrq+1);
    
    pos = 0;
    for i = ixFrq
        pos = pos + 1;
        iFreq = freq(i);
        iDelta = kr(i);
        iY = y(:,i);
        doOneFrequency();
    end
    
    [Obj(:,iLoop),V,Delta,PDelta] = kalman.oolik(L0,L1,L2,L3,nObs,LikOpt);
    
    if s.isObjOnly
        continue
    end
    
    RegOutp.V(1,iLoop) = V;
    RegOutp.Delta(:,iLoop) = Delta;
    RegOutp.PDelta(:,:,iLoop) = PDelta;
    
end


% Nested functions...


%**************************************************************************
    function doOneFrequency()
        nObs(1,1+pos) = iDelta*nYIncl;
        ZiW = Z / ((eye(size(T)) - T*exp(-1i*iFreq)));
        G = ZiW*Sa*ZiW' + Sy;
        G(diagInx) = real(G(diagInx));
        L0(1,1+pos) = iDelta*real(log(det(G)));
        L1(1,1+pos) = iDelta*real((y(:,i)'/G)*iY);
        if isOutOfLik
            MtGi = M(:,:,i)'/G;
            L2(:,:,1+pos) = iDelta*real(MtGi*M(:,:,i));
            L3(:,1+pos) = iDelta*real(MtGi*iY);
        end
    end % doOneFrequency()


end