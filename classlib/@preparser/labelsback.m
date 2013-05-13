function C = labelsback(C,Labels,Format)
% labelsback  [Not a public function] Replace #(...) with the corresponding string.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    Format;
catch %#ok<CTCH>
    Format = '''%s''';
end

%--------------------------------------------------------------------------

if isempty(C)
    return
end

replaceFunc = @doReplace; %#ok<NASGU>
C = regexprep(C,'#\((\d+)\)','${replaceFunc($1)}');

    function s = doReplace(s)
        inx = sscanf(s,'%g');
        s = Labels{inx};
        if ~isempty(Format)
            s = sprintf(Format,s);
        end
    end % doReplace().

end

