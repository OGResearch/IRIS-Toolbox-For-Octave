function [W,List] = ifrf(This,Freq,varargin)
% ifrf  Frequency response function to shocks.
%
% Syntax
% =======
%
%     [W,List] = ifrf(M,Freq,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object for which the frequency response function
% will be computed.
%
% * `Freq` [ numeric ] - Vector of frequencies for which the response
% function will be computed.
%
% Output arguments
% =================
%
% * `W` [ numeric ] - Array with frequency responses of transition
% variables (in rows) to shocks (in columns).
%
% * `List` [ cell ] - List of transition variables in rows of the `W`
% matrix, and list of shocks in columns of the `W` matrix.
%
% Options
% ========
%
% * `'matrixFmt='` [ *`'namedmat'`* | `'plain'` ] - Return matrix `W` as
% either a [`namedmat`](namedmat/Contents) object (i.e. matrix with named
% rows and columns) or a plain numeric array.
%
% * `'select='` [ *`@all`* | char | cellstr ] - Return IFRF for selected
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

% Parse input arguments.
pp = inputParser();
pp.addRequired('Freq',@isnumeric);
pp.parse(Freq);

% Parse options.
opt = passvalopt('model.ifrf',varargin{:});

isSelect = ~isequal(opt.select,@all);
isNamedMat = strcmpi(opt.MatrixFmt,{'namedmat'});

%--------------------------------------------------------------------------

Freq = Freq(:)';
nFreq = length(Freq);
ny = length(This.solutionid{1});
nx = length(This.solutionid{2});
ne = length(This.solutionid{3});
nAlt = size(This.Assign,3);
W = zeros(ny+nx,ne,nFreq,nAlt);

if ne > 0
    isSol = true(1,nAlt);
    for iAlt = 1 : nAlt
        [T,R,K,Z,H,D,Za,Omg] = mysspace(This,iAlt,false);
        
        % Continue immediately if solution is not available.
        isSol(iAlt) = all(~isnan(T(:)));
        if ~isSol(iAlt)
            continue
        end
        
        % Call Freq Domain package.
        W(:,:,:,iAlt) = freqdom.ifrf(T,R,K,Z,H,D,Za,Omg,Freq);
    end
end

% Report NaN solutions.
if ~all(isSol)
    utils.warning('model:ifrf', ...
        'Solution(s) not available %s.', ...
        preparser.alt2str(~isSol));
end

% Variables and shocks in rows and columns of `W`.
rowNames = [This.solutionvector{1:2}];
colNames = This.solutionvector{3};
    
% Select variables if requested.
if isSelect
    [W,pos] = select(W,rowNames,colNames,opt.select);
    rowNames = rowNames(pos{1});
    colNames = colNames(pos{2});
end
List = {rowNames,colNames};

if true % ##### MOSW
    % Convert output matrix to namedmat object if requested.
    if isNamedMat
        W = namedmat(W,rowNames,colNames);
    end
else
    % Do nothing.
end

end
