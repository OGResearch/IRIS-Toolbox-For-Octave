function [X,List,D] = fmse(This,Time,varargin)
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
% * `F` [ numeric ] - Forecast MSE matrices.
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
% * `'output='` [ *'namedmat'* | numeric ] - Output matrix `M` will be
% either a namedmat object or a plain numeric array; if the option
% `'select='` is used, `'output='` is always `'namedmat'`.
%
% * `'select='` [ cellstr | *`Inf`* ] - Return FMSE for selected variables
% only; `Inf` means all variables. The option does not apply to the
% output database `D`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

opt = passvalopt('model.fmse',varargin{:});

if ischar(opt.select)
    opt.select = regexp(opt.select,'\w+','match');
end

% tell whether time is nper or range
if length(Time) == 1 && round(Time) == Time && Time > 0
    range = 1 : Time;
else
    range = Time(1) : Time(end);
end
nPer = length(range);

isSelect = iscellstr(opt.select);
isNamedmat = strcmpi(opt.output,'namedmat') || isSelect;

%--------------------------------------------------------------------------

ny = length(This.solutionid{1});
nx = length(This.solutionid{2});
nAlt = size(This.Assign,3);
X = zeros(ny+nx,ny+nx,nPer,nAlt);

% Compute FMSE for all available parameterisations.
[flag,inx] = isnan(This,'solution');
for iAlt = find(~inx)
    [T,R,K,Z,H,D,U,Omg] = mysspace(This,iAlt,false);
    X(:,:,:,iAlt) = timedom.fmse(T,R,K,Z,H,D,U,Omg,nPer);
end

% Some solution(s) not available.
if flag
    utils.warning('model', ...
        '#Solution_not_available', ...
        sprintf(' #%g',find(inx)));
end

List = [This.solutionvector{1:2}];

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

% Convert output matrix to namedmat object.
if isNamedmat
    X = namedmat(X,List,List);
end

% Select variables.
if isSelect
    X = select(X,opt.select);
end

end