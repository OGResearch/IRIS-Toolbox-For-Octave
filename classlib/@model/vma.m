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
% * `'output='` [ *`'namedmat'`* | `'numeric'` ] - Output matrix `Phi` will
% be either a namedmat object or a plain numeric array; if the option
% `'select='` is used, `'output='` is always `'namedmat'`.
%
% * `'select='` [ cellstr | *`Inf`* ] - Return the VMA matrices for
% selected variabes and/or shocks only; `Inf` means all variables.
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

if ischar(opt.select)
    opt.select = regexp(opt.select,'\w+','match');
end

isSelect = iscellstr(opt.select);
isNamedmat = strcmpi(opt.output,'namedmat') || isSelect;

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

% List of variables in rows (measurement and transion) and columns (shocks)
% of output matrices.
List = { ...
    [This.solutionvector{1:2}], ...
    This.solutionvector{3}, ...
    };

% Convert output matrix to namedmat object.
if isNamedmat
    Phi = namedmat(Phi,List{1},List{2});
end

% Select variables.
if isSelect
    Phi = select(Phi,opt.select);
end

end