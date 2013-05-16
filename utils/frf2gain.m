function F = frf2gain(F,varargin)
% frf2gain  Gain of frequency response function.
%
% Syntax
% =======
%
%     G = frf2gain(F)
%
% Input arguments
% ================
%
% * `F` [ numeric ] - Frequency response function.
%
% Output arguments
% =================
%
% * `G` [ numeric ] - Gain of frequency response function.
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

isNamed = isa(F,'namedmat');

if isNamed
    row = rownames(F);
    col = colnames(F);
end
    
F = abs(F);

if isNamed
    F = namedmat(F,row,col);
end

end