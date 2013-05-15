function varargout = caption(This,varargin)
% caption  Get or set user captions in an IRIS object.
%
% Syntax for getting user captions
% =================================
%
%     Cpt = caption(Obj)
%
% Syntax for assigning user captions
% ===================================
%
%     Obj = comment(Obj,Cpt)
%
% Input arguments
% ================
%
% * `Obj` [ model | tseries | VAR | SVAR | FAVAR | sstate ] -
% One of the IRIS objects.
%
% * `Cpt` [ char ] - User caption that will be attached to the object.
%
% Output arguments
% =================
%
% * `Cpt` [ char ] - User caption that are currently attached to the
% object.
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

if ~isempty(varargin)
    P = inputParser();
    P.addRequired('Cpt',@ischar);
    P.parse(varargin{1});
end

if isempty(varargin)
    varargout{1} = This.Caption;
else
    This.Caption = varargin{1};
    varargout{1} = This;
end

end