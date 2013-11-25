function [X,Flag] = specget(This,Query)
% specget  [Not a public function] Implement get method for SVAR class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

[X,Flag] = specget@svarobj(This,Query);
if Flag
    return
end

[X,Flag] = specget@VAR(This,Query);

end