function This = reporting(P)
% reporting  [Not a public function] Parse reporting equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% TODO: Create a separate reporting object, and make this function its
% method.

%--------------------------------------------------------------------------

This.lhs = {};
This.rhs = {};
This.label = {};
This.userRHS = {};

P.code = strtrim(P.code);
if isempty(P.code)
    return
end

ptn = ['(?<label>[',regexppattern(P.labels),'])?', ...
    '\s*(?<lhs>\w+)\s*=\s*(?<rhs>.*?)\s*(?<nan>\|.*?)?;',];
tok = regexp(P.code,ptn,'names');

This.label = {tok(:).label};
This.label = restore(This.label,P.labels,'delimiter=',false);
This.lhs = {tok(:).lhs};
This.rhs = {tok(:).rhs};
This.nan = {tok(:).nan};

% Preserve the original user-supplied RHS expressions.
% Add a semicolon at the end.
This.userRHS = regexprep(This.rhs,'(.)$','$1;');

% Add (:,t) to names (or names with curly braces) not followed by opening
% bracket or dot and not preceded by !
This.rhs = regexprep(This.rhs, ...
    '(?<!!)(\<[a-zA-Z]\w*\>(\{.*?\})?)(?![\(\.])','$1#');

% Add prefix d. to all names consisting potentially of \w and \. not followed by opening bracket.
if ismatlab
    This.rhs = regexprep(This.rhs,'\<[a-zA-Z][\w\.]*\>(?!\()','?$0');
else
    This.rhs = myregexprep(This.rhs,'\<[a-zA-Z][\w\.]*\>(?!\()','${[''?'',$0]}');
end

This.rhs = strrep(This.rhs,'#','(t,:)');
This.rhs = strrep(This.rhs,'?','d.');

This.rhs = strrep(This.rhs,'!','');

% Vectorise *, /, \, ^ operators.
This.rhs = strfun.vectorise(This.rhs);

This.nan = strtrim(strrep(This.nan,'|',''));
for i = 1 : length(This.nan)
    This.nan{i} = str2num(This.nan{i}); %#ok<ST2NM>
end
index = cellfun(@isempty,This.nan) | ~cellfun(@isnumeric,This.nan);
This.nan(index) = {NaN};

% Remove blank spaces from RHSs.
for i = 1 : length(This.rhs)
    This.rhs{i}(isspace(This.rhs{i})) = '';
end

end