function [Code,Labels] = protectlabels(Code,Labels)
% protectlabels  [Not a public function] Replace labels with #(...) code.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    Labels;
catch %#ok<CTCH>
    Labels = {};
end

%--------------------------------------------------------------------------

    function C = doProcessLabel(Text)
        Labels{end+1} = Text;
        C = sprintf('#(%g)',length(Labels));
    end % doProcessLabel().

replaceFunc = @doProcessLabel; %#ok<NASGU>
% '\1' cannot be used within [^...], therefore we cannot exclude the
% opening quote (either apostrophe or double quote) from the string.
Code = regexprep(Code,'([''"])([^\n]*?)\1','${replaceFunc($2)}');

end