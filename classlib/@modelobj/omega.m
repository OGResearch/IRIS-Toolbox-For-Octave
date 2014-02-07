function varargout = omega(This,Omg,IAlt)
% omega  Get or set the covariance matrix of shocks.
%
% Syntax for getting covariance matrix
% =========================================
%
%     OMG = omega(M)
%
% Syntax for setting covariance matrix
% =====================================
%
%     M = omega(M,OMG)
%
% Input arguments
% ================
%
% * `M` [ model | bkwmodel ] - Model or bkwmodel object.
%
% * `OMG` [ numeric ] - Covariance matrix that will be converted to new
% values for std deviations and cross-corr coefficients.
%
% Output arguments
% =================
%
% * `OMG` [ numeric ] - Covariance matrix of shocks or residuals based on
% the currently assigned std deviations and cross-correlation coefficients.
%
% * `M` [ model | bkwmodel ] - Model or bkwmodel object with new values
% for std deviations and cross-corr coefficients based on the input
% covariance matrix.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

try
    Omg; 
catch
    Omg = [];
end

try
    if isequal(IAlt,Inf)
        IAlt = ':';
    end
catch
    IAlt = ':';
end

%--------------------------------------------------------------------------

if isempty(Omg)
    % Create Omega from stdcorr.
    ne = sum(This.nametype == 3);
    stdcorr = permute(This.stdcorr(1,:,IAlt),[2,3,1]);
    Omg = covfun.stdcorr2cov(stdcorr,ne);
    varargout{1} = Omg;
    varargout{2} = stdcorr;
else
    % Assign stdcorr from Omega.
    Omg = Omg(:,:,:);
    stdcorr = covfun.cov2stdcorr(Omg);
    stdcorr = permute(stdcorr,[3,1,2]);
    nalt = size(This.stdcorr(1,:,IAlt),3);
    if size(stdcorr,3) < nalt
        stdcorr(1,:,end+1:nalt) = stdcorr(1,:,end*ones([1,nalt-end]));
    end
    This.stdcorr(1,:,IAlt) = stdcorr(:,:,IAlt);
    varargout{1} = This;
end

end