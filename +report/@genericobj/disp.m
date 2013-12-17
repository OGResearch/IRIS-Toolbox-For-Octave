function disp(This,Level)
% disp  Display the structure of a report object.
%
% Help provided in +report/disp.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    Level; %#ok<VUNUS>
catch %#ok<CTCH>
    Level = 0;
end

%--------------------------------------------------------------------------

tab = sprintf('\t');
fprintf('%s',tab(ones(1,1+Level)));
if Level > 0
    fprintf('+');
end

fprintf('%s',shortclass(This));
if ~isempty(This.caption)
    if iscell(This.caption)
        cap = This.caption{1};
    else
        cap = This.caption;
    end
    fprintf(' ''%s''',cap);
end
fprintf('\n');

for i = 1 : length(This.children)
    disp(This.children{i},Level+1);
end

if Level == 0
    strfun.loosespace();
end

end