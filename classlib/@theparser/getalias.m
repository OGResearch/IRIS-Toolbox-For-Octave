function [Label,Alias] = getalias(Label)
% splitlabels [Not a public function] Split labels into labels and aliases.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(Label)
    Alias = Label;
    return
end

Alias = cell(size(Label));
Alias (:) = {''};
for i = 1 : length(Label)
    pos = strfind(Label{i},'!!');
    if isempty(pos)
        continue
    end
    Alias{i} = Label{i}(pos+2:end);
    Label{i} = Label{i}(1:pos-1);
end
Alias = strtrim(Alias);
Label = strtrim(Label);

end