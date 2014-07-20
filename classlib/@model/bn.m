function Outp = bn(This,Inp,Range,varargin)
% bn  Beveridge-Nelson trends.
%
% Syntax
% =======
%
%     Outp = bn(M,Inp,Range,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Solved model object.
%
% * `Inp` [ struct | cell ] - Input data on which the BN trends will be
% computed.
%
% * `Range` [ numeric ] - Date range on which the BN trends will be
% computed.
%
% Output arguments
% =================
%
% * `Outp` [ struct | cell ] - Output data with the BN trends.
%
% Options
% ========
%
% * `'deviations='` [ `true` | *`false`* ] - Input and output data are
% deviations from balanced-growth paths.
%
% * `'dtrends='` [ *`@auto`* | `true` | `false` ] - Measurement variables
% in input and output data include deterministic trends specified in
% [`!dtrends`](modellang/dtrends) equations.
%
% Description
% ============
%
% The BN decomposition is accurate only if the input data have been
% generated using unanticipated shocks.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Parse required input arguments.
pp = inputParser();
pp.addRequired('Inp',@(x) isstruct(x) || iscell(x));
pp.addRequired('Range',@(x) isnumeric(x));
pp.parse(Inp,Range);

opt = passvalopt('model.bn',varargin{:});

%--------------------------------------------------------------------------

nx = length(This.solutionid{2});
nb = size(This.solution{1},2);
nf = nx - nb;
ne = length(This.solutionid{3});
ng = sum(This.nametype == 5);
nAlt = size(This.Assign,3);
Range = Range(1) : Range(end);
nPer = length(Range);

% Alpha vector.
A = datarequest('alpha',This,Inp,Range);
nData = size(A,3);

% Exogenous variables.
G = datarequest('g',This,Inp,Range);

% Total number of output data sets.
nLoop = max([nData,nAlt]);

% Pre-allocate hdataobj for output data.
hd = hdataobj(This,Range,nLoop,'IncludeLag=',false);

repeat = ones(1,nPer);
isSol = true(1,nAlt);
isDiffStat = true(1,nAlt);

for iLoop = 1 : nLoop
    
    
    g = G(:,:,min(iLoop,end));
    if iLoop <= nAlt
        T = This.solution{1}(:,:,iLoop);
        Tf = T(1:nf,:);
        Ta = T(nf+1:end,:);
        
        % Continue immediate if solution is not available.
        isSol(iLoop) = all(~isnan(T(:)));
        if ~isSol(iLoop)
            continue
        end
        
        nUnit = mynunit(This,iLoop);
        if ~iseye(Ta(1:nUnit,1:nUnit))
            isDiffStat(iLoop) = false;
            continue
        end
        Z = This.solution{4}(:,:,iLoop);
        U = This.solution{7}(:,:,iLoop);
        if ~opt.deviation
            Ka = This.solution{3}(nf+1:end,1,iLoop);
            aBar = zeros(nb,1);
            aBar(nUnit+1:end) = ...
                (eye(nb-nUnit) - Ta(nUnit+1:end,nUnit+1:end)) ...
                \ Ka(nUnit+1:end);
            aBar = aBar(:,repeat);
            Kf = This.solution{3}(1:nf,1,iLoop);
            D = This.solution{6};
            Kf = Kf(:,repeat);
            D = D(:,repeat);
        end
        if opt.dtrends
            W = mydtrendsrequest(This,'range',Range,g,iLoop);
        end
    end
    
    a = A(:,:,min(iLoop,end));
    if ~opt.deviation
        a = a - aBar;
    end
    
    % Forward cumsum of stable alpha.
    aCum = (eye(nb-nUnit) - Ta(nUnit+1:end,nUnit+1:end)) ...
        \ a(nUnit+1:end,:);
    
    % Beveridge Nelson for non-stationary variables.
    a(1:nUnit,:) = a(1:nUnit,:) + ...
        Ta(1:nUnit,nUnit+1:end)*aCum;
    
    if opt.deviation
        a(nUnit+1:end,:) = 0;
    else
        a(nUnit+1:end,:) = aBar(nUnit+1:end,:);
    end
    
    xf = Tf*a;
    xb = U*a;
    y = Z*a;
    
    if ~opt.deviation
        xf = xf + Kf;
        y = y + D;
    end
    if opt.dtrends
        y = y + W;
    end
    
    % Store output data #iloop.
    x = [xf;xb];
    e = zeros(ne,nPer);
    hdataassign(hd,iLoop, { y,x,e,[],g } );
    
end

% Report NaN solutions.
if ~all(isSol)
    utils.warning('model', ...
        'Solution(s) not available %s.', ...
        preparser.alt2str(~isSol));
end

% Parameterisations that are not difference-stationary.
if any(~isDiffStat)
    utils.warning('model', ...
        ['Cannot run Beveridge-Nelson on models with ', ...
        'I(2) or higher processes %s.'], ...
        preparser.alt2str(~isDiffStat));
end

% Create output database from hdataobj.
Outp = hdata2tseries(hd);

end
