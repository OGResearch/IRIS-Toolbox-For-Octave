function [Value,IsValid] = eval(Exp,Asgn,Labels)
% eval  [Not a public function] Evaluate !if, !switch and $(...)$ expressions within the assign database.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Exp = strtrim(Exp);
Exp = strrep(Exp,'!','');

% Add `D.` to all of its fields.
if isstruct(Asgn)
    list = fieldnames(Asgn)';
else
    list = {};
end
for i = 1 : length(list)
    Exp = regexprep(Exp,['(?<![\.!])\<',list{i},'\>'],['?.',list{i}]);
end
Exp = strrep(Exp,'?.','Asgn.');

% Put labels back because some of them can be strings in !if or !switch
% expressions.
Exp = restore(Exp,Labels);

% Evaluate the expression.
try
    Value = eval(Exp);
    IsValid = true;
catch %#ok<CTCH>
    Value = false;
    IsValid = false;
end

end