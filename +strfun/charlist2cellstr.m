function [Strings,Labels] = charlist2cellstr(X,Sep)
% charlist2cellstr  [Not a public function] OBSOLETE. Convert character list to cell array of strings.

% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    Sep; %#ok<VUNUS>
catch %#ok<CTCH>
    Sep = ',;\n';
end

%--------------------------------------------------------------------------

X = strtrim(X);
X = strfun.converteols(X);
X = strfun.removecomments(X);

% Separators , ; end-of-line
pattern = '(?<label>["''].*?["''])?\s*(?<string>[^"''#]*?)\s*(?=[#]|$)';
pattern = strrep(pattern,'#',Sep);
y = regexp(X,pattern,'names');
Strings = {y(:).string};
Labels = {y(:).label};
% remove double quotes from labels
for i = 1 : length(Labels)
    Labels{i} = Labels{i}(2:end-1);
end

end
