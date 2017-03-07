function Flag = issolved(m)
% issolved  True if a model solution exists.
%
% Syntax
% =======
%
%     flag = issolved(m)
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object.
%
% Output arguments
% =================
%
% * `flag` [ `true` | `false` ] - True for each parameterisation for which a
% stable unique solution has been found and exists currently in the model
% object.
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

T = m.solution{1};
nAlt = size(T,3);

% Models with no equations return `false`.
if size(T,1) == 0
    Flag = false(1,nAlt);
    return
end

[~,Flag] = isnan(m,'solution');
Flag = ~Flag;

end
