function varargout = isstationary(This,varargin)
% isstationary  True if model or specified combination of variables is stationary.
%
% Syntax
% =======
%
%     Flag = isstationary(M)
%     Flag = isstationary(M,Expn)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `Expn` [ char ] - Text string with an expression describing a
% combination of transition variables to be tested.
%
% Output arguments
% =================
%
% * `'flag='` [ `true` | `false` ] - True if the model (if called without a
% second input argument) or the specified combination of variables (if
% called with a second input argument) is stationary.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

eigValTol = This.Tolerance(1);

if isempty(varargin)
    % Called flag = isstationary(model).
    if isempty(This.solution{1})
        varargout{1} = NaN;
    else
        nb = size(This.solution{1},2);
        varargout{1} = ...
            permute(all(abs(This.eigval(1,1:nb,:)) < 1-eigValTol,2), ...
            [1,3,2]);
    end
else
    % Called [flag,...] = isstationary(model,expression,...).
    [varargout{1:length(varargin)}] = ...
        xxIsCointegrated(This,varargin{:});
end

end

% Subfunctions.

%**************************************************************************
function varargout = xxIsCointegrated(This,varargin)

[nx,nb,nAlt] = size(This.solution{1});
realSmall = getrealsmall();
xVector = This.solutionvector{2};

varargout = cell(1,length(varargin));
for iArg = 1 : length(varargin)
    exprn = varargin{iArg};
    w = preparser.lincomb2vec(exprn,xVector);
    nf = nx - nb;
    flag = false(1,nAlt);
    for iAlt = 1 : nAlt
        Tf = This.solution{1}(1:nf,:,iAlt);
        U = This.solution{7}(:,:,iAlt);
        nUnit = mynunit(This,iAlt);
        test = w*[Tf(:,1:nUnit);U(:,1:nUnit)];
        flag(iAlt) = all(abs(test) <= realSmall);
    end
    varargout{iArg} = flag;
end

end % xxIsCointegrated().