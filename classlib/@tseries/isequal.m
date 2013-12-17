function Flag = isequal(This,That)
% isequal  [Not a public function] Compare two tseries objects.
%
% Syntax
% =======
%
%     Flag = isequal(X1,X2)
%
% Input arguments
% ================
%
% * `X1`, `X2` [ tseries ] - Two tseries objects that will be compared.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if the two input tseries objects
% have identical contents: start date, data, comments, userdata, and
% captions.
%
% Description
% ============
%
% The function `isequaln` is used to compare the tseries data, i.e. `NaN`s
% are correctly matched.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = isequal@userdataobj(This,That) ...
    && isequaln(This.start,That.start) ...
    && isequaln(This.data,That.data);

end