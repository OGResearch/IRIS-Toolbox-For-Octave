function C = cleanup(C,This)
% cleanup  [Not a public function] Remove all replacement codes belonging
% to a given fragileobj from a string.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isnan(This.Offset) || isempty(This.Storage)
    return
end

for i = 1 : length(This)
    ptn = [char(2),dec2char(This,i),char(3)];
    C = strrep(C,ptn,'');
end

end