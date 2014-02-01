function This = loadobj(This)
% loadobj  [Not a public function] Prepare tmsobj for use in workspace and handle bkw compatibility.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isfield(This,'ynames')
    This.Ynames = This.ynames;
end

if isfield(This,'enames')
    This.Enames = This.enames;
end

if isstruct(This)
    This = VAR(This);
end

end