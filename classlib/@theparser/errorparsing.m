function S = errorparsing(This)
% errorparsing [Not a public function] Report the file name when the parser fails.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

S = sprintf( ...
    'Error parsing file(s) <a href="matlab: edit %s">%s</a>. ', ...
    strrep(This.fname,' & ',' '),This.fname);

end