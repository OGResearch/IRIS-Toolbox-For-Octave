function S = errorparsing(This)

fname = specget(This,'file');
S = sprintf( ...
    'Error parsing file(s) <a href="matlab: edit %s">%s</a>. ', ...
    strrep(fname,' & ',' '),fname);

end