function s = vectorise(s)
% vectorise  Replace matrix operators with elementwise operators.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

isCellInp = iscell(s);
if ~isCellInp
    s = {s};
end

%--------------------------------------------------------------------------


func = @(v) regexprep(v,'(?<!\.)(\*|/|\\|\^)','.$1');

valid = true(size(s));
n = numel(s);
for i = 1 : n
    if isempty(s{i})
        continue
    elseif ischar(s{i})
        s{i} = func(s{i});
    elseif isa(s{i},'function_handle')
        c = char(s{i});
        c = func(c);
        s{i} = str2func(c);
    else
        valid(i) = false;
    end
end

if any(~valid)
    utils.error('strfun:vectorise', ...
        ['Cannot vectorise expressions other than ', ...
        'char strings or function handles.']);
end

if ~isCellInp
    s = s{1};
end

end