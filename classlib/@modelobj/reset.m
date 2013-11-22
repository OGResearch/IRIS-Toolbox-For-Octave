function This = reset(This,varargin)
% reset  Reset specific values within model object.
%
% Syntax
% =======
%
%     M = reset(M)
%     M = reset(M,Req1,Req2,...)
%
% Input arguments
% ================
%
% * `M` [ model ] -  Model object in which the requested type(s) of values
% will be reset.
%
% * `Req1`, `Req2`, ... [ `'corr'` | `'parameters'` | `'sstate'` | `'std'`
% | `'stdcorr'` ] - Requested type(s) of values that will be reset; if
% omitted, everything will be reset.
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with the requested values reset.
%
% Description
% ============
%
% * `'corr'` - All cross-correlation coefficients will be reset to `0`.
%
% * `'parameters'` - All parameters will be reset to `NaN`.
%
% * `'sstate'` - All steady state values will be reset to `NaN`.
%
% * `'std'` - All std deviations will be reset to `1` (in linear models) or
% `log(1.01)` (in non-linear models).
%
% * `'stdcorr'` - Equivalent to `'std'` and `'corr'`.
%
% Example
% ========
%
% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------
 
ne = sum(This.nametype == 3);

if This.linear
    std = 1;
else
    std = 0.01;
end

if isempty(varargin)
    doResetSstate();
    doResetParams();
    doResetStd();
    doResetCorr();
    return
end

for i = 1 : length(varargin)
    x = lower(strtrim(varargin{i}));
    switch lower(strtrim(x))
        case {'sstate','steadystate'}
            doResetSstate();
        case {'parameters','params'}
            doResetParams();
        case 'stdcorr'
            doResetStd();
            doResetCorr();
        case 'std'
            doResetStd();
        case 'corr'
            doResetCorr();
    end
end

% Nested functions.

%**************************************************************************
    function doResetSstate()
        inx = This.nametype ~= 4;
        This.Assign(1,inx,:) = NaN;
    end % doResetSstate().

%**************************************************************************
    function doResetParams()
        inx = This.nametype == 4;
        This.Assign(1,inx,:) = NaN;
    end % doResetParams().

%**************************************************************************
    function doResetStd()
        This.stdcorr(1:ne,:,:) = std;
    end % doResetStd().

%**************************************************************************
    function doResetCorr()
        This.stdcorr(ne+1:end,:,:) = 0;
    end % doResetCorr().

end