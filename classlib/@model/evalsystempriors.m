function [P,C,X] = evalsystempriors(This,S)
% evalsystempriors  Evaluate minus log of system prior density.
%
% Syntax
% =======
%
%     [P,C,X] = evalsystempriors(M,S)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object on which current parameterisation the
% system priors will be evaluated.
%
% * `S` [ systempriors ] - System priors objects.
%
% Output arguments
% =================
%
% * `P` [ numeric ] - Minus log of system prior density.
%
% * `C` [ numeric ] - Contributions of individual prios to the overall
% system prior density.
%
% * `X` [ numeric ] - Value of each system property for which a prior has
% been defined in the system priors object, `S`.
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

ny = sum(This.nametype == 1);
ne = sum(This.nametype == 3);
nxx = length(This.solutionid{2});
nAlt = size(This.Assign,3);
ns = length(S);

P = nan(1,nAlt);
C = nan(1,ns,nAlt);
X = nan(1,ns,nAlt);

for iAlt = 1 : nAlt
    % Current state space matrices.
    T = This.solution{1}(:,:,iAlt);
    R = This.solution{2}(:,1:ne,iAlt);
    Z = This.solution{4}(:,:,iAlt);
    H = This.solution{5}(:,:,iAlt);
    U = This.solution{7}(:,:,iAlt);
    Omg = omega(This,[],iAlt);
    Eig = This.eigval(1,:,iAlt);
    
    % Shock response function.
    SRF = [];
    if ~isempty(S,'srf')
        nper = max(S.systemFunc.srf.page);
        shockSize = S.shockSize;
        SRF = nan(ny+nxx,ne,nper);
        active = S.systemFunc.srf.activeInput;
        Phi = timedom.srf(T,R(:,active),[],Z,H(:,active),[],U,[], ...
            nper,shockSize(active));
        SRF(:,active,:) = Phi(:,:,2:end);
    end
    
    % Frequency response function.
    FFRF = [];
    if ~isempty(S,'ffrf')
        freq = S.systemFunc.ffrf.page;
        incl = Inf;
        FFRF = freqdom.ffrf3(T,R,[],Z,H,[],U,Omg,freq,incl,[],[]);
    end
    
    % Covariance function.
    COV = [];
    if ~isempty(S,'cov') || ~isempty(S,'corr') || ~isempty(S,'spd')
        order = max(S.systemFunc.cov.page);
        COV = covfun.acovf(T,R,[],Z,H,[],U,Omg,Eig,order);
    end
    
    % Correlation function.
    CORR = [];
    if ~isempty(S,'corr')
        CORR = covfun.cov2corr(COV,'acf');
    end
    
    % Power spectrum function.
    PWS = [];
    if ~isempty(S,'pws') || ~isempty(S,'spd')
        freq = S.systemFunc.pws.page;
        PWS = freqdom.xsf(T,R,[],Z,H,[],U,Omg,freq);
    end
    
    % Spectral density function.
    SPD = [];
    if ~isempty(S,'spd')
        SPD = freqdom.psf2sdf(PWS,COV(:,:,1));
    end
    
    % Parameter values and steady states.
    Assign = This.Assign(1,:,1);
    stdcorr = This.stdcorr(1,:,1);
    
    % Evaluate prior log densities.
    x = nan(1,ns);
    c = nan(1,ns);
    p = 0;
    for is = 1 : ns
        x(is) = S.eval{is}(SRF,FFRF,COV,CORR,PWS,SPD,Assign,stdcorr);
        if x(is) < S.lowerBound(is) || x(is) > S.upperBound(is)
            c(is) = Inf;
        elseif ~isempty(S.priorFunc{is})
            c(is) = S.priorFunc{is}(x(is));
        else
            % Empty prior function handle means uniform distribution.
            c(is) = 0;
        end
        % Minus log density.
        c(is) = -c(is);
        p = p + c(is);
        if ~isfinite(p)
            p = Inf;
            break
        end
    end

    P(1,iAlt) = p;
    C(1,:,iAlt) = c;
    X(1,:,iAlt) = x;
    
end

end