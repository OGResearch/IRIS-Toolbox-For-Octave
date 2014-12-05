function [Y0,K0,X0,Y1,G1,CI] = mystackdata(This,Y,X,Opt) %#ok<INUSL>
% mystackdata  [Not a public function] Re-arrange data for VAR estimation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.
 
%--------------------------------------------------------------------------

% Plain (non-panel) input data are stored in 1-by-1 cell arrays, as are
% 1-group panel VARs.

nGrp = length(Y);
ny = size(Y{1},1);
nx = size(X{1},1);
nAlt = size(Y{1},3);
nXPer = size(Y{1},2); % nXPer is the same for each group because Range cannot be Inf for panel VARs.
p = Opt.order;

% Endogenous variables
%----------------------
YInp = Y;
Y = [];
for iGrp = 1 : nGrp
    % Separate groups by a total of `p` NaNs.
    Y = [Y,YInp{iGrp},nan(ny,p,nAlt)]; %#ok<AGROW>
end
n = size(Y,2);

% Constant including fixed effect
%---------------------------------
K0 = zeros(0,n);
if Opt.constant
    if Opt.fixedeff
        % Dummy constants for fixed-effect panel estimation.
        K0 = zeros(nGrp,0);
        for iGrp = 1 : nGrp
            k = zeros(nGrp,nXPer+p);
            k(iGrp,1:nXPer) = 1;
            k(iGrp,nXPer:end) = NaN;
            K0 = [K0,k]; %#ok<AGROW>
        end
    else
        K0 = ones(1,n);
    end
end

% Exogenous inputs including fixed effect
%-----------------------------------------
X0 = zeros(0,n);
if nx > 0
    if Opt.fixedeff
        X0 = zeros(nGrp*nx,0);
        for iGrp = 1 : nGrp
            x = zeros(nGrp*nx,nXPer+p,nAlt);
            pos = (iGrp-1)*nx + (1 : nx);
            x(pos,1:nXPer,:) = X{iGrp};
            x(pos,nxPer:end,:) = NaN;
            X0 = [X0,x]; %#ok<AGROW>
        end
    else
        X0 = zeros(nx,0);
        for iGrp = 1 : nGrp
            X0 = [X0,X{iGrp},nan(nx,p,nAlt)]; %#ok<AGROW>
        end
    end
end

% Cointegrating vectors
%-----------------------
% Only one set of cointegrating vectors allowed.
CI = Opt.cointeg;
if isempty(CI)
    CI = zeros(0,1+ny);
else
    if size(CI,2) == ny
        CI = [ones(size(CI,1),1),CI];
    end
end
ng = size(CI,1);

G1 = zeros(ng,n,nAlt);

if ~Opt.diff
    
    % Level VAR
    %-----------
    Y0 = Y;
    Y1 = nan(p*ny,n,nAlt);
    for i = 1 : p
        Y1((i-1)*ny+(1:ny),1+i:end,:) = Y(:,1:end-i,:);
    end
    
else
    
    % VEC or difference VAR
    %-----------------------
    dY = nan(size(Y));
    dY(:,2:end,:) = Y(:,2:end,:) - Y(:,1:end-1,:);
    % Current dated and lagged differences of endogenous variables.
    % Add the co-integrating vector and differentiate data.
    kg = ones(1,n);
    if ~isempty(CI)
        for iLoop = 1 : nAlt
            x = nan(ny,n);
            x(:,2:end) = Y(:,1:end-1,iLoop);
            % Lag of the co-integrating vector.
            G1(:,:,iLoop) = CI*[kg;x];
        end
    end
    Y0 = dY;
    Y1 = nan((p-1)*ny,n,nAlt);
    for i = 1 : p-1
        Y1((i-1)*ny+(1:ny),1+i:end,:) = dY(:,1:end-i,:);
    end
    
end

end