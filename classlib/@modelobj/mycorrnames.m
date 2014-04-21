function List = mycorrnames(This)
% mycorrnames  [Not a public function] List of primary names for correlation coefficients (lower triangular).
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

eList = This.name(This.nametype == 3);
ne = length(eList);
List = {};
for i = 2 : ne
    for j = 1 : i-1
        List{end+1} = sprintf('corr_%s__%s',eList{i},eList{j}); %#ok<AGROW>
    end
end

end