function S = vectorise(S)
% vectorise  [Not a public function] Replace matrix operators with elementwise operators.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

isCellInp = iscell(S);
if ~isCellInp
    S = {S};
end

%--------------------------------------------------------------------------

func = @(v) regexprep(v,'(?<!\.)(\*|/|\\|\^)','.$1');

valid = true(size(S));
n = numel(S);
for i = 1 : n
    if isempty(S{i})
        continue
    elseif ischar(S{i})
        S{i} = feval(func,S{i});
    elseif isfunc(S{i})
        c = func2str(S{i});
        c = feval(func,c);
        S{i} = mosw.str2func(c);
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
    S = S{1};
end

end
