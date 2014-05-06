function [C,Invalid] = pseudosubs(C,Asgn,Labels)
% pseudosubs  [Not a public function] Evaluate pseudosubstitutions $(...)$.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Invalid = {};
while true
    [match,start,finish] = regexp(C,'\$\[.*?\]\$','match','once');
    if isempty(match)
        break
    end
    expr = strtrim(match(3:end-2));    
    if ~isempty(expr)
        [value,valid] = preparser.eval(expr,Asgn,Labels);
        if is.numericscalar(value)
            value = sprintf('%g',value);
        elseif isequal(value,true)
            value = 'true';
        elseif isequal(value,false)
            value = 'false';
        end
        valid = valid && ischar(value);
    else
        value = '';
        valid = true;
    end
    if valid
        C = [C(1:start-1),value,C(finish+1:end)];
    else
        C(start:finish) = '';
        Invalid{1,end+1} = match; %#ok<AGROW>
    end
end

end