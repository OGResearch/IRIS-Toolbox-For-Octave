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
% * `'output='` [ *`'namedmat'`* | `'numeric'` ] - Output matrix `W` will
% be either a namedmat object or a plain numeric array; if the option
% `'select='` is used, `'output='` is always `'namedmat'`.
%
% * `'select='` [ char | cellstr | *`Inf`* ] - Return the frequency
% response function only for selected variables and/or selected shocks.
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
pp.addRequired('m',@(isArg)is.model(isArg));
pp.addRequired('freq',@isnumeric);
pp.parse(This,Freq);


% Parse options.
opt = passvalopt('model.ifrf',varargin{:});

isSelect = iscellstr(opt.select);
isNamedmat = strcmpi(opt.output,'namedmat') || isSelect;

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
    utils.warning('model', ...
        'Solution(s) not available %s.', ...
        preparser.alt2str(~isSol));
end

List = { ...
    [This.solutionvector{1:2}], ...
    This.solutionvector{3}, ...
    };
    
if isNamedmat
    W = namedmat(W,List{1},List{2});
end

% Select variables.
if isSelect
    W = select(W,opt.select);
end

end