function S = errorparsing(This)
% errorparsing  [Not a public function] Create "Error parsing" message.
%
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

fname = specget(This,'file');

S = sprintf( ...
    'Error parsing file(s) <a href="matlab: edit %s">%s</a>. ', ...
    strrep(fname,' & ',' '),fname);

end