function varargout = comment(this,varargin)
% comment  Get or set user comments in an IRIS object.
%
% Syntax for getting user comments
% =================================
%
%     C = comment(OBJ)
%
% Syntax for assigning user comments
% ===================================
%
%     OBJ = comment(OBJ,C)
%
% Input arguments
% ================
%
% * `OBJ` [ model | tseries | VAR | SVAR | FAVAR | sstate ] -
% One of the IRIS objects.
%
% * `C` [ char ] - User comment that will be attached to the object.
%
% Output arguments
% =================
%
% * `C` [ char ] - User comment that are currently attached to
% the object.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

if ~isempty(varargin)
    P = inputParser();
    P.addRequired('comment',@ischar);
    P.parse(varargin{1});
end
if isempty(varargin)
    varargout{1} = this.Comment;
else
    this.Comment = varargin{1};
    varargout{1} = this;
end

end