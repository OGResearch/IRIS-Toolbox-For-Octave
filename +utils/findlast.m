function Pos = findlast(X)
% findlast  Find the last non-zero or true value in 2nd dimension.
%
% Syntax
% =======
%
%     Pos = utils.findlast(X);
%
% Input arguments
% ================
%
% * `X` [ logical | numeric ] - A logical or numeric matrix
% (3-dimensional at most).
%
% Output arguments
% =================
%
% * `Pos` [ numeric ] - The 2nd-dimension position of the last `true` or
% last non-zero value in any row or any page of `X`; returns `0` if non
% `true` or non-zero value exists.
%
% Description
% ============
%
% If `X` is a numeric array, all `NaN` values are first reset to zero
% before looking up the position of the last non-zero value.
%
% Example
% ========
%
% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(X)
    Pos = 0;
    return
end

if ~islogical(X)
    X(isnan(X)) = 0;
    X = X ~= 0;
end

Pos = max([0,find(any(any(X,3),1),1,'last')]);

end