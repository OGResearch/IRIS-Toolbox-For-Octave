function varargout = userdata(this,varargin)
% userdata  Get or set user data in an IRIS object.
%
% Syntax for getting user data
% =============================
%
%     X = userdata(OBJ)
%
% Syntax for assigning user data
% ===============================
%
%     OBJ = userdata(OBJ,X)
%
% Input arguments
% ================
%
% * `OBJ` [ model | tseries | VAR | SVAR | FAVAR | sstate ] -
% One of the IRIS objects with access to user data functions.
%
% * `X` [ ... ] - Any kind of data that will be attached to, and stored
% within, the object `OBJ`.
%
% Output arguments
% =================
%
% * `X` [ ... ] - User data that are currently attached to the
% object.
%
% * `OBJ` [ model | tseries | VAR | SVAR | FAVAR | sstate ] - The object
% with its user data updated.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

if isempty(varargin)
    varargout{1} = this.UserData;
else
    this.UserData = varargin{1};
    varargout{1} = this;
end

end