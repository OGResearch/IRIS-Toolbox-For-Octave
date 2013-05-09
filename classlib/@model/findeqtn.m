function varargout = findeqtn(This,varargin)
% findeqtn  Find equations by the labels.
%
% Syntax
% =======
%
%     [Eqtn,Eqtn,...] = findeqtn(M,Label,Label,...)
%     [List,List,...] = findeqtn(M,'-rexp',Rexp,Rexp,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object in which the equations will be searched
% for.
%
% * `Label` [ char ] - Equation label that will be searched for.
%
% * `Rexp` [ char ] - Regular expressions that will be matched against
% equation labels.
%
% Output arguments
% =================
%
% * `Eqtn` [ char ] - First equation found with the label `Label`.
%
% * `List` [ cellstr ] - List of equations whose labels match the regular
% expression `Rexp`.
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

if nargin < 2
    return
end

[varargout{1:nargout}] = myfind(This,'findeqtn',varargin{:});

end
