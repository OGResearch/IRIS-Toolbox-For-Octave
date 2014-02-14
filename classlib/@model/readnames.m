function [name,nametype,shocktype,label,value] = readnames(block)
% readnames  [Not a public function] Read individual names from declaration blocks.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

name = [];
nametype = [];
shocktype = [];
label = {};
value = {};

for i = [4,12,11,2,1]
    [namei,labeli,valuei] = theparser.parsenames(block{i});
    name = [namei,name]; %#ok<*AGROW>
    label = [labeli,label];
    value = [valuei,value];
    ni = length(namei);
    switch (i)
        % Do not assign steady states to the shocks.
        case 12
            % Transition shocks.
            nametype = [3*ones(1,ni),nametype];
            shocktype = [2*ones(1,ni),shocktype];
        case 11
            % Measurement shocks.
            nametype = [3*ones(1,ni),nametype];
            shocktype = [1*ones(1,ni),shocktype];
        otherwise
            % Parameters, transition, and measurement variables.
            nametype = [i*ones(1,ni),nametype];
            shocktype = [nan(1,ni),shocktype];
    end
end

end