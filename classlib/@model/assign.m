function [This,varargout] = assign(varargin)
% assign  Assign parameters, steady states, std deviations or cross-correlations.
%
% Syntax
% =======
%
%     [M,Assigned] = assign(M,P)
%     [M,Assigned] = assign(M,Name,Value,Name,Value,...)
%     [M,Assigned] = assign(M,List,Values)
%
% Syntax for fast assign
% =======================
%
%     % Initialise
%     assign(M,List);
%
%     % Fast assign
%     M = assign(M,Values);
%     ...
%     M = assign(M,Values);
%     ...
%
% Syntax for assigning only steady-state levels
% ==============================================
%
%     M = assign(M,'-level',...)
%
% Syntax for assignin only steady-state growth rates
% ===================================================
%
%     M = assign(M,'-growth',...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `P` [ struct | model ] - Database whose fields refer to parameter
% names, variable names, std deviations, or cross-correlations; or another
% model object.
%
% * `Name` [ char ] - A parameter name, variable name, std
% deviation, cross-correlation, or a regular expression that will be
% matched against model names.
%
% * `Value` [ numeric ] - A value (or a vector of values in case of
% multiple parameterisations) that will be assigned.
%
% * `List` [ cellstr ] - A list of parameter names, variable names, std
% deviations, or cross-correlations.
%
% * `Values` [ numeric ] - A vector of values.
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with newly assigned parameters and/or
% steady states.
%
% * `Assigned` [ cellstr | `Inf` ] - List of actually assigned parameter
% names, variables names (steady states), std deviations, and
% cross-correlations; `Inf` indicates that all values has been assigned
% from another model object.
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

[This,varargout{1:nargout-1}] = assign@modelobj(varargin{:});

% Housekeeping.

% Steady states of shocks can only be zero.
inx = This.nametype == 3;
This.Assign(1,inx,:) = 0;

% Only measurement, transition and exogenous variables can have imaginary
% parts.
inx = This.nametype == 3 | This.nametype == 4;
This.Assign(1,inx,:) = real(This.Assign(1,inx,:));

end