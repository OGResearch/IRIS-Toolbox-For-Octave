function [List,Lab] = labeledexpr(List)
% labeledexpr  [Not a public function] Parse labeled expressions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

isRetChar = ischar(List);
if isRetChar
    List = {List};
end

%--------------------------------------------------------------------------

nlist = length(List);
Lab = cell(1,nlist);
Lab(:) = {''};

List = strtrim(List);

for i = 1 : nlist
    [lab,to] = regexp(List{i},'([''"]).*?\1','match','end','once');
    if ~isempty(lab)
        Lab{i} = lab(2:end-1);
        List{i}(1:to) = '';
        List{i} = strtrim(List{i});
    end
end

if isRetChar
    List = List{1};
    Lab = Lab{1};
end

end