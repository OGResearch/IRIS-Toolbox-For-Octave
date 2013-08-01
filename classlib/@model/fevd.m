function [X,Y,List,XX,YY] = fevd(This,Time,varargin)
% fevd  Forecast error variance decomposition for model variables.
%
% Syntax
% =======
%
%     [X,Y,List,A,B] = fevd(M,Range,...)
%     [X,Y,List,A,B] = fevd(M,NPer,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object for which the decomposition will be
% computed.
%
% * `Range` [ numeric ] - Decomposition date range with the first date
% beign the first forecast period.
%
% * `NPer` [ numeric ] - Number of periods for which the decomposition will
% be computed.
%
% Output arguments
% =================
%
% * `X` [ namedmat | numeric ] - Array with the absolute contributions of
% individual shocks to total variance of each variables.
%
% * `Y` [ namedmat | numeric ] - Array with the relative contributions of
% individual shocks to total variance of each variables.
%
% * `List` [ cellstr ] - List of variables in rows of the `X` an `Y`
% arrays, and shocks in columns of the `X` and `Y` arrays.
%
% * `A` [ struct ] - Database with the absolute contributions converted to
% time series.
%
% * `B` [ struct ] - Database with the relative contributions converted to
% time series.
%
% Options
% ========
%
% * `'output='` [ *'namedmat'* | numeric ] - Output matrices `X` and `Y`
% will be either namedmat objects or plain numeric arrays; if the option
% `'select='` is used, `'output='` is always `'namedmat'`.
%
% * `'select='` [ char | cellstr ] - Return FEVD for selected variables
% and/or shocks only; `Inf` means all variables. This option does not apply
% to the output databases, `A` and `B`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Parse options.
opt = passvalopt('model.fevd',varargin{:});

if ischar(opt.select)
    opt.select = regexp(opt.select,'\w+','match');
end

% Tell whether time is nper or range.
if length(Time) == 1 && round(Time) == Time && Time > 0
    range = 1 : Time;
else
    range = Time(1) : Time(end);
end
nPer = length(range);

isSelect = iscellstr(opt.select);
isNamedmat = strcmpi(opt.output,'namedmat') || isSelect;

%--------------------------------------------------------------------------

ny = sum(This.nametype == 1);
nx = length(This.solutionid{2});
ne = sum(This.nametype == 3);
nAlt = size(This.Assign,3);
X = nan([ny+nx,ne,nPer,nAlt]);
Y = nan([ny+nx,ne,nPer,nAlt]);

isZeroCorr = true(1,nAlt);
isSolution = true(1,nAlt);
for iAlt = 1 : nAlt
    
    % Continue immediately if some cross-corrs are non-zero.
    isZeroCorr(iAlt) = all(This.stdcorr(1,ne+1:end,iAlt) == 0);
    if ~isZeroCorr(iAlt)
        continue
    end
    
    [T,R,K,Z,H,D,Za,Omg] = mysspace(This,iAlt,false);
    
    % Continue immediately if solution is not available.
    isSolution(iAlt) = all(~isnan(T(:)));
    if ~isSolution(iAlt)
        continue
    end
    
    [Xi,Yi] = timedom.fevd(T,R,K,Z,H,D,Za,Omg,nPer);
    X(:,:,:,iAlt) = Xi;
    Y(:,:,:,iAlt) = Yi;
end

% Report NaN solutions.
if ~all(isSolution)
    utils.warning('model', ...
        'Solution(s) not available:%s.', ...
        preparser.alt2str(~isSolution));
end

% Report non-zero cross-correlations.
if ~all(isZeroCorr)
    utils.warning('model', ...
        ['Cannot compute FEVD for parameterisations with ', ...
        'non-zero cross-correlations:%s.'], ...
        preparser.alt2str(~isZeroCorr));
end

List = {[This.solutionvector{1:2}],This.solutionvector{3}};

% Convert arrays to tseries databases.
if nargout > 3
    % Select only current dated variables.
    id = [This.solutionid{1:2}];
    name = This.name(real(id));
    eEame = This.name(This.nametype == 3);
    XX = struct();
    YY = struct();
    for i = find(imag(id) == 0)
        c = regexprep(eEame,'.*',[List{1}{i},' <-- $0']);
        XX.(name{i}) = tseries(range,permute(X(i,:,:,:),[3,2,4,1]),c);
        YY.(name{i}) = tseries(range,permute(Y(i,:,:,:),[3,2,4,1]),c);
    end
    % Add parameter database.
    for j = find(This.nametype == 4)
        XX.(This.name{j}) = permute(This.Assign(1,j,:),[1,3,2]);
        YY.(This.name{j}) = XX.(This.name{j});
    end
end

% Convert output matrices to namedmat objects.
if isNamedmat
    X = namedmat(X,List{1},List{2});
    Y = namedmat(Y,List{1},List{2});
end

% Select variables; selection only applies to the matrix outputs, `X`
% and `Y`, and not to the database outputs, `x` and `y`.
if isSelect
    [X,inx] = select(X,opt.select);
    if nargout > 1
        Y = Y(inx{1},inx{2},:,:);
    end
end

end