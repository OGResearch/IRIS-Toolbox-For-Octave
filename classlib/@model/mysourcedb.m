function Outp = mysourcedb(This,Range,varargin)
% mysourcedb  [Not a public function] Create model-specific source database.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

nCol = [];
if ~isempty(varargin) && is.numericscalar(varargin{1})
    nCol = varargin{1};
    varargin(1) = [];
end

% Parse options.
opt = passvalopt('model.sourcedb',varargin{:});

nDraw = opt.ndraw;
if isempty(nCol)
    nCol = opt.ncol;
end

if strcmp(opt.dtrends,'auto')
    opt.dtrends = ~opt.deviation;
end

if ~isnumeric(Range)
    error('Incorrect type of input argument(s).');
end

%--------------------------------------------------------------------------

nAlt = size(This.Assign,3);

if (nCol > 1 && nAlt > 1) ...
        || (nDraw > 1 && nAlt > 1)
    utils.error('model', ...
        ['The options `''ncol=''` or `''ndraw=''` can be used only with ', ...
        'single parameterisation models.']);
end

nf = sum(imag(This.solutionid{2}) > 2);
maxLag = -(min(imag(This.solutionid{2}(nf+1:end))) - 1);
nPer = length(Range);
xRange = Range(1)-maxLag : Range(end);
nXPer = length(xRange);

n1 = sum(This.nametype == 1);
n2 = sum(This.nametype == 2);
n3 = sum(This.nametype == 3);
ng = sum(This.nametype == 5);

if nCol > 1 && nAlt > 1
    utils.error('model', ...
        ['Input argument NCOL can be used only with ', ...
        'single-parameterisation models.']);
end

n = n1 + n2 + n3;
nLoop = max([nAlt,nCol,nDraw]);
Outp = struct();

% Deterministic time trend.
timeTrend = dat2ttrend(xRange,This);

%tVec = double(round(xRange - xRange(1)));
if opt.deviation
    X = zeros(n,nXPer,nAlt);
    G = zeros(ng,nXPer,nAlt);
else
    X = zeros(n,nXPer,nAlt);
    inx = find(This.nametype == 1 | This.nametype == 2);
    X(inx,:,:) = mytrendarray(This,inx,timeTrend,false,Inf);
    G = mytrendarray(This,find(This.nametype == 5),timeTrend,false,Inf);
end

if opt.dtrends
    D = mydtrendsrequest(This,'range',xRange,G);
    X(1:n1,:,:) = X(1:n1,:,:) + D;
end

X(This.log(1:n),:,:) = exp(X(This.log(1:n),:,:));

if nLoop > 1 && nAlt == 1
    X = X(:,:,ones(1,nLoop));
    G = G(:,:,ones(1,nLoop));
end

% Measurement variables, transition variables, shocks.
tmp = tseries();
for i = find(This.nametype <= 3)
    Outp.(This.name{i}) = replace(tmp,permute(X(i,:,:),[2,3,1]), ...
        xRange(1),This.namelabel{i});
end

% Generate random residuals if requested.
if opt.randomshocks
    Outp = xxRandomShocks(This,Outp,nPer,maxLag,nLoop,nDraw);
elseif ~isempty(opt.residuals)
    % SOURCEDB not implemented yet for models with cross-correlations.
    ne = sum(This.nametype == 3);
    if any(any(This.stdcorr(1,ne+1:end,:) ~= 0))
        utils.error('model', ...
            ['Source databases with ''residuals'' option ', ...
            'not implemented yet for models with cross-correlated shocks.']);
    end
    Outp = xxAddRand(This,Outp,opt.residuals,nXPer,nLoop);
end

% Add parameters.
for i = find(This.nametype == 4)
    Outp.(This.name{i}) = permute(This.Assign(1,i,:),[1,3,2]);
end

% Add exogenous variables.
offset = sum(This.nametype < 5);
for i = find(This.nametype == 5)
    Outp.(This.name{i}) = ...
        replace(tmp,permute(G(i-offset,:,:),[2,3,1]), ...
        xRange(1),This.namelabel{i});    
end

% Add time trend.
Outp.ttrend = replace(tmp,timeTrend.',xRange(1),'Time trend');    

end

% Subfunctions.

%**************************************************************************
function D = xxAddRand(This,D,Func,NPer,NLoop)
nAlt = size(This.Assign,3);
ne = sum(This.nametype == 3);
eList = This.name(This.nametype == 3);
stdvec = This.stdcorr(1,1:ne,:);
for ie = 1 : ne
    x = zeros(1,NPer,NLoop);
    for iloop = 1 : NLoop
        if iloop <= nAlt
            std = stdvec(1,ie,iloop);
        end
        x(1,:,iloop) = Func(std,[1,NPer]);
    end
    D.(eList{ie}) = replace(D.(eList{ie}),permute(x,[2,3,1]));
end
end % xxAddRand().

%**************************************************************************
function D = xxRandomShocks(This,D,NPer,MaxLag,NLoop,NDraw)
ne = sum(This.nametype == 3);
nAlt = size(This.Assign,3);
eList = This.name(This.nametype == 3);
for iloop = 1 : NDraw
    if iloop <= nAlt
        Omg = covfun.stdcorr2cov(This.stdcorr(1,:,iloop),ne);
        F = covfun.factorise(Omg);
    end
    e = F*randn(ne,NPer);
    for i = 1 : ne
        name = eList{i};
        if NDraw == 1
            D.(name).data(MaxLag+1:end,1:NLoop) = e(i*ones(1,NLoop),:).';
        else
            D.(name).data(MaxLag+1:end,iloop) = e(i,:).';
        end
    end
end
end % xxRandomShocks().