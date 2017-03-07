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

P.Code = strtrim(P.Code);
if isempty(P.Code)
    return
end

ptn = [ ...
    '((',regexppattern(P.Labels),')?)\s*', ... % Label.
    '(\w+)\s*=\s*', ... % LHS.
    '([^\|;]+)', ... % RHS.
    '((\|[^;]*)?);', ... % Nan.
    ];
tok = regexp(P.Code,ptn,'tokens');
tok = [tok{:}];

This.label = tok(1:4:end);
This.label = restore(This.label,P.Labels,'delimiter=',false);
This.lhs = tok(2:4:end);
This.rhs = strtrim(tok(3:4:end));
This.nan = strtrim(tok(4:4:end));

% Preserve the original user-supplied RHS expressions.
% Add a semicolon at the end.
This.userRHS = strcat(This.rhs,';');

% Add (:,t) to names (or names with curly braces) not followed by opening
% bracket or dot and not preceded by !
This.rhs = regexprep(This.rhs, ...
    '(?<!!)(\<[a-zA-Z]\w*\>(\{.*?\})?)(?![\(\.])','$1#');

% Add prefix ? to all names consisting potentially of \w and \. not
% followed by opening bracket.
This.rhs = regexprep(This.rhs,'(\<[a-zA-Z][\w\.]*\>)(?!\()','?$1');

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
