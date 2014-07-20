function [X,YXVec,D] = fmse(This,Time,varargin)
% fmse  Forecast mean square error matrices.
%
% Syntax
% =======
%
%     [F,List,D] = fmse(M,NPer,...)
%     [F,List,D] = fmse(M,Range,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object for which the forecast MSE matrices will
% be computed.
%
% * `NPer` [ numeric ] - Number of periods.
%
% * `Range` [ numeric ] - Date range.
%
% Output arguments
% =================
%
% * `F` [ namedmat | numeric ] - Forecast MSE matrices.
%
% * `List` [ cellstr ] - List of variables in rows and columns of `M`.
%
% * `D` [ dbase ] - Database with the std deviations of
% individual variables, i.e. the square roots of the diagonal elements of
% `F`.
%
% Options
% ========
%
% * `'matrixFmt='` [ *`'namedmat'`* | `'plain'` ] - Return matrix `F` as
% either a [`namedmat`](namedmat/Contents) object (i.e. matrix with named
% rows and columns) or a plain numeric array.
%
% * `'select='` [ *`@all`* | char | cellstr ] - Return FMSE for selected
% variables only; `@all` means all variables.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

opt = passvalopt('model.fmse',varargin{:});

% tell whether time is nper or range
if length(Time) == 1 && round(Time) == Time && Time > 0
    range = 1 : Time;
else
    range = Time(1) : Time(end);
end
nPer = length(range);

isSelect = ~isequal(opt.select,@all);
isNamedMat = strcmpi(opt.MatrixFmt,{'namedmat'});

%--------------------------------------------------------------------------

ny = length(This.solutionid{1});
nx = length(This.solutionid{2});
nAlt = size(This.Assign,3);
X = zeros(ny+nx,ny+nx,nPer,nAlt);

isSol = true(1,nAlt);
for iAlt = 1 : nAlt
    [T,R,K,Z,H,D,U,Omg] = mysspace(This,iAlt,false);
    
    % Continue immediately if solution is not available.
    isSol(iAlt) = all(~isnan(T(:)));
    if ~isSol(iAlt)
        continue
    end
    
    X(:,:,:,iAlt) = timedom.fmse(T,R,K,Z,H,D,U,Omg,nPer);
end

% Report NaN solutions.
if ~all(isSol)
    utils.warning('model:fmse', ...
        'Solution(s) not available %s.', ...
        preparser.alt2str(~isSol));
end

% Database of std deviations.
if nargout > 2
    % Select only contemporaneous variables.
    id = [This.solutionid{1:2}];
    D = struct();
    for i = find(imag(id) == 0)
        name = This.name{id(i)};
        D.(name) = tseries(range,sqrt(permute(X(i,i,:,:),[3,4,1,2])));
    end
    for j = find(This.nametype == 4)
        D.(This.name{j}) = permute(This.Assign(1,j,:),[1,3,2]);
    end
end

if nargout <= 1 && ~isSelect && ~isNamedMat
    return
end

YXVec = myvector(This,'yx');

% Select variables if requested.
if isSelect
    [X,pos] = select(X,YXVec,YXVec,opt.select);
    pos = pos{1};
    YXVec = YXVec(pos);
end

if true % ##### MOSW
    % Convert output matrix to namedmat object if requested.
    if isNamedMat
        X = namedmat(X,YXVec,YXVec);
    end
else
    % Do nothing.
end

end
