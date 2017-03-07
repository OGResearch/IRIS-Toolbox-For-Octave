function This = loadobj(This)
% loadobj  [Not a public function] Prepare varobj for use in workspace and handle bkw compatibility.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isstruct(This)
    This = VAR(This);
end

end