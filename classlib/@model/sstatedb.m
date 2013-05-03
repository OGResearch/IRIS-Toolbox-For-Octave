function [D,Dev] = sstatedb(This,Range,varargin)
% sstatedb  Create model-specific steady-state or balanced-growth-path database
%
% Syntax
% =======
%
%     [D,IsDev] = sstatedb(M,Range)
%     [D,IsDev] = sstatedb(M,Range,NCol)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object for which the sstate database will be
% created.
%
% * `Range` [ numeric ] - Intended simulation range; the steady-state or
% balanced-growth-path database will be created on a range that also
% automatically includes all the necessary lags.
%
% * `NCol` [ numeric ] - Number of columns for each variable; the input
% argument `NCol` can be only used with single-parameterisation models.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Database with a steady-state or balanced-growth path
% tseries object for each model variable, and a scalar or vector of the
% currently assigned values for each model parameter.
%
% * `IsDev` [ `false` ] - The second output argument is always `false`, and
% can be used to set the option `'deviation='` in
% [`model/simulate`](model/simulate).
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% zerodb, sstatedb

%--------------------------------------------------------------------------

[Flag,List] = isnan(This,'sstate');
if Flag
    utils.warning('model', ...
        'Steady state for this variables is NaN: ''%s''.', ...
        List{:});
end

D = mysourcedb(This,Range,varargin{:},'deviation',false);
Dev = false;

end