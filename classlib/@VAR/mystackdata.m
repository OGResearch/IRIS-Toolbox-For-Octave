function [Y0,K0,Y1,G1,CI,NGrp] = mystackdata(This,Y,Opt) %#ok<INUSL>
% mystackdata  [Not a public function] Re-arrange data for VAR estimation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.
 
% Pretend plain VAR is a panel VAR with one group of data.
if ~iscell(Y)
    Y = {Y};
end

%--------------------------------------------------------------------------

NGrp = length(Y);
ny = size(Y{1},1);
nAlt = size(Y{1},3);
p = Opt.order;

YInp = Y;
Y = [];
K0 = [];
for iGrp = 1 : NGrp
    % Separate groups by a total of `p` NaNs.
    y = [YInp{iGrp},nan(ny,p,nAlt)];
    Y = [Y,y]; %#ok<AGROW>
    if Opt.constant
        if Opt.fixedeffect
            % Dummy constants for fixed-effect panel estimation.
            k0 = zeros(NGrp,size(y,2));
            k0(iGrp,:) = 1;
        else
            k0 = ones(1,size(y,2));
        end
    else
        k0 = zeros(0,size(y,2));
    end
    K0 = [K0,k0]; %#ok<AGROW>
end
n = size(Y,2);

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