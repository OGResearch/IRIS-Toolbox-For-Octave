function This = horzcat(This,varargin)
% horzcat  Combine two compatible model objects in one object with multiple parameterisations.
%
% Syntax
% =======
%
%     M = [M1,M2,...]
%
% Input arguments
% ================
%
% * `M1`, `M2` [ model ] - Compatible model objects that will be combined;
% the input models must be based on the same model file.
%
% Output arguments
% =================
%
% * `M` [ model ] - Output model object that combines the input model
% objects as multiple parameterisations.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin == 1
    return
end

for i = 1 : numel(varargin)
    inx = size(This.Assign,3) + (1 : size(varargin{i}.Assign,3));
    This = mysubsalt(This,inx,varargin{i},':');
end

end