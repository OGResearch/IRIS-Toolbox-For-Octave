function [Phi,List] = vma(This,NPer,varargin)
% vma  Vector moving average representation of the model.
%
% Syntax
% =======
%
%     [Phi,List] = vma(M,P,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object for which the VMA representation will be
% computed.
%
% * `P` [ numeric ] - Order up to which the VMA will be evaluated.
%
% Output arguments
% =================
%
% * `Phi` [ namedmat | numeric ] - VMA matrices.
%
% * `List` [ cell ] - List of measurement and transition variables in
% the rows of the `Phi` matrix, and list of shocks in the columns of the
% `Phi` matrix.
%
% Option
% =======
%
% * `'matrixFmt='` [ *`'namedmat'`* | `'plain'` ] - Return matrix `Phi`
% as either a [`namedmat`](namedmat/Contents) object (i.e. matrix with
% named rows and columns) or a plain numeric array.
%
% * `'select='` [ *`@all`* | char | cellstr ] - Return VMA for selected
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

opt = passvalopt('model.vma',varargin{:});

isSelect = ~isequal(opt.select,@all);
isNamedMat = strcmpi(opt.MatrixFmt,{'namedmat'});

%--------------------------------------------------------------------------

ny = length(This.solutionid{1});
nx = length(This.solutionid{2});
ne = length(This.solutionid{3});
nAlt = size(This.Assign,3);

Phi = zeros(ny+nx,ne,NPer+1,nAlt);
isSol = true(1,nAlt);
for iAlt = 1 : nAlt
   [T,R,K,Z,H,D,U,Omg] = mysspace(This,iAlt,false);
   
    % Continue immediately if solution is not available.
    isSol(iAlt) = all(~isnan(T(:)));
    if ~isSol(iAlt)
        continue
    end
   
   Phi(:,:,:,iAlt) = timedom.srf(T,R,K,Z,H,D,U,Omg,NPer,1);
end

% Remove pre-sample period.
Phi(:,:,1,:) = [];

% Report NaN solutions.
if ~all(isSol)
    utils.warning('model', ...
        'Solution(s) not available %s.', ...
        preparser.alt2str(~isSol));
end

if nargout <= 1 && ~isSelect && ~isNamedMat
    return
end

% List of variables in rows (measurement and transion) and columns (shocks)
% of matrix `Phi`.
rowNames = myvector(This,'yx');
colNames = myvector(This,'e');

% Select variables if requested.
if isSelect
    [Phi,pos] = select(Phi,rowNames,colNames,opt.select);
    rowNames = rowNames(pos{1});
    colNames = colNames(pos{2});    
end
List = {rowNames,colNames};

if true % ##### MOSW
    % Convert output matrix to namedmat object if requested.
    if isNamedMat
        Phi = namedmat(Phi,rowNames,colNames);
    end
else
    % Do nothing.
end

end
