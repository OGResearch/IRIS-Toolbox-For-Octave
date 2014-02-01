function [Rad,Per] = frf2phase(F,varargin)
% frf2phase  Phase shift of frequence response function.
%
% Syntax
% =======
%
%     [Rad,Per] = frf2phase(F)
%
% Input arguments
% ================
%
% * `F` [ numeric ] - Frequency response matrices computed by `ffrf`.
%
% Output arguments
% =================
%
% * `Rad` [ numeric ] - Phase shift in radians.
%
% * `Per` [ numeric ] - Phase shift in periods.
%
% Options
% ========
%
% See help on `xsf2phase` for options available.
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

isNamedmat = isa(F,'namedmat');
if isNamedmat
    row = rownames(F);
    col = colnames(F);
end

[Rad,Per] = xsf2phase(F,varargin{:});

if isNamedmat
    Rad = namedmat(Rad,row,col);
    if nargin > 1 && ~isempty(Per)
        Per = namedmat(Per,row,col);
    end
end
