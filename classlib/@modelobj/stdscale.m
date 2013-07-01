function m = stdscale(m,factor)
% stdscale  Re-scale all std deviations by the same factor.
%
% Syntax
% =======
%
%     m = stdscale(m,factor)
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object whose std deviations will be re-scaled.
%
% * `factor` [ numeric ] - Factor by which all the model std deviations
% will be re-scaled.
%
% Output arguments
% =================
%
% * `m` [ model ] - Model object with all of its std deviations re-scaled.
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

factor = factor(:);
if all(factor == 1)
    return
end

nfactor = length(factor);
nalt = size(m.Assign,3);
ne = sum(m.nametype == 3);
if nfactor == 1
    m.stdcorr(1,1:ne,:) = m.stdcorr(1,1:ne,:)*factor;
else
    factor = factor(1:nalt);
    factor = permute(factor,[3,2,1]);
    factor = factor(:,ones([1,ne]),:);
    m.stdcorr(1,1:ne,:) = m.stdcorr(1,1:ne,:) .* factor;
end

end
