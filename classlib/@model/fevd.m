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
% * `'matrixFmt='` [ *`'namedmat'`* | `'plain'` ] - Return matrices `X`
% and `Y` as be either [`namedmat`](namedmat/Contents) objects (i.e.
% matrices with named rows and columns) or plain numeric arrays.
%
% * `'select='` [ `@all` | char | cellstr ] - Return FEVD for selected
% variables and/or shocks only; `@all` means all variables and shocks; this
% option does not apply to the output databases, `A` and `B`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Parse options.
opt = passvalopt('model.fevd',varargin{:});

% Tell whether time is nPer or Range.
if length(Time) == 1 && round(Time) == Time && Time > 0
    range = 1 : Time;
else
    range = Time(1) : Time(end);
end
nPer = length(range);

isSelect = ~isequal(opt.select,@all);
isNamedMat = isanystri(opt.MatrixFmt,{'namedmat'});

%--------------------------------------------------------------------------

ny = sum(This.nametype == 1);
nx = length(This.solutionid{2});
ne = sum(This.nametype == 3);
nAlt = size(This.Assign,3);
X = nan(ny+nx,ne,nPer,nAlt);
Y = nan(ny+nx,ne,nPer,nAlt);

isZeroCorr = true(1,nAlt);
isSol = true(1,nAlt);
for iAlt = 1 : nAlt
    
    % Continue immediately if some cross-corrs are non-zero.
    isZeroCorr(iAlt) = all(This.stdcorr(1,ne+1:end,iAlt) == 0);
    if ~isZeroCorr(iAlt)
        continue
    end
    
    [T,R,K,Z,H,D,Za,Omg] = mysspace(This,iAlt,false);
    
    % Continue immediately if solution is not available.
    isSol(iAlt) = all(~isnan(T(:)));
    if ~isSol(iAlt)
        continue
    end
    
    [Xi,Yi] = timedom.fevd(T,R,K,Z,H,D,Za,Omg,nPer);
    X(:,:,:,iAlt) = Xi;
    Y(:,:,:,iAlt) = Yi;
end

% Report NaN solutions.
if ~all(isSol)
    utils.warning('model:fevd', ...
        'Solution(s) not available %s.', ...
        preparser.alt2str(~isSol));
end

% Report non-zero cross-correlations.
if ~all(isZeroCorr)
    utils.warning('model:fevd', ...
        ['Cannot compute FEVD with ', ...
        'nonzero cross-correlations %s.'], ...
        preparser.alt2str(~isZeroCorr));
end

if nargout <= 2 && ~isSelect && ~isNamedMat
    return
end

rowNames = myvector(This,'yx');
colNames = myvector(This,'e');

% Convert arrays to tseries databases.
if nargout > 3
    % Select only current dated variables.
    id = [This.solutionid{1:2}];
    name = This.name(real(id));

    XX = struct();
    YY = struct();
    for i = find(imag(id) == 0)
        c = strcat(rowNames{i},' <-- ',colNames);
        XX.(name{i}) = tseries(range,permute(X(i,:,:,:),[3,2,4,1]),c);
        YY.(name{i}) = tseries(range,permute(Y(i,:,:,:),[3,2,4,1]),c);
    end
    % Add parameter database.
    XX = addparam(This,XX);
    YY = addparam(This,YY);
end

% Select variables if requested; selection only applies to the matrix
% outputs, `X` and `Y`, and not to the database outputs, `x` and `y`.
if isSelect
    [X,pos] = select(X,rowNames,colNames,opt.select);
    rowNames = rowNames(pos{1});
    colNames = colNames(pos{2});
    if nargout > 1
        Y = Y(pos{1},pos{2},:,:);
    end
end
List = {rowNames,colNames};

if true % ##### MOSW
    % Convert output matrices to namedmat objects if requested.
    if isNamedMat
        X = namedmat(X,rowNames,colNames);
        if nargout > 1
            Y = namedmat(Y,rowNames,colNames);
        end
    end
else
    % Do nothing.
end

end
