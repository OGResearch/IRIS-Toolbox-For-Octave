function varargout = tolerance(This,varargin)
% tolerance  Get or set eigenvalue tolerance.
%
% Syntax for getting tolerance
% =============================
%
%     Tol = tolerance(M)
%
% Syntax for setting tolerance
% =============================
%
%     M = tolerance(M,Tol)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `Tol` [ numeric ] - New level of eigenvalue tolerance that will be
% set in the model object.
%
% Output arguments
% =================
%
% * `Tol` [ numeric ] - Currently assigned level of tolerance.
%
% * `M` [ model ] - Model object with the new level of tolerance set.
%
% Description
% ============
%
% Never use this function unless you really know what you are doing.
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(varargin)
    varargout{1} = This.Tolerance;
elseif length(varargin) == 1
    This.Tolerance(:) = varargin{1}(:);
    varargout{1} = This;
    utils.warning('model', ...
        ['You should NEVER reset eigenvalue tolerance unless you are ', ...
        'absolutely sure about what you are doing.']);
end

end