function This = horzcat(This,varargin)
% horzcat  Combine two compatible VAR objects in one object with multiple parameterisations.
%
% Syntax
% =======
%
%     V = [V1,V2,...]
%
% Input arguments
% ================
%
% * `V1`, `V2` [ VAR ] - Compatible VAR objects that will be combined.
%
% Output arguments
% =================
%
% * `V` [ VAR ] - Output VAR object that combines the input VAR
% objects as multiple parameterisations.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

pp = inputParser();
if ismatlab
pp.addRequired('v1',@(x) isa(x,'VAR'));
pp.addRequired('v2',@(x) all(cellfun(@(y) isa(y,'VAR'),x)));
pp.parse(This,varargin);
else
pp = pp.addRequired('v1',@(x) isa(x,'VAR'));
pp = pp.addRequired('v2',@(x) all(cellfun(@(y) isa(y,'VAR'),x)));
pp = pp.parse(This,varargin);
end

%--------------------------------------------------------------------------

if nargin == 1
   return
end

for i = 1 : numel(varargin)
    inx = size(This.A,3) + (1 : size(varargin{1}.A,3));
    This = mysubsalt(This,inx,varargin{i},':');
end

end