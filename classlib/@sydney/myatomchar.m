function C = myatomchar(This)
% myatomchar  [Not a public function] Print sydney atom to char string.
%
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

a = This.args;
fmt = '%.15g';
if ischar(a)
    % Name of a variable.
    C = a;
elseif isnumericscalar(a)
    % Constant.
    if a == 0
        C = '0';
    else
        C = sprintf(fmt,a);
    end
elseif (isnumeric(a) || islogical(a)) ...
        && ~isempty(a) && length(size(a)) == 2 && size(a,2) == 1
    % Column vector.
    C = sprintf([';',fmt],double(a));
    C = ['[',C(2:end),']'];
else
    utils.error('sydney:char', ...
        'Unknown type of sydney atom.');
end

end
