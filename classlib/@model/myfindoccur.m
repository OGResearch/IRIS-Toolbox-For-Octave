function [Time,Name] = myfindoccur(This,Eq,Type)
% myfindoccur  [Not a public function] Find occurences of names in an equation.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

nName = length(This.name);
occur = This.occur(Eq,:);
occur = reshape(occur,[nName,size(This.occur,2)/nName]);
occur = occur.';

switch Type
    case 'variables_shocks'
        % Occurences of variables and shocks.
        occur = occur(:,This.nametype <= 3);
        [Time,Name] = find(occur);
    case 'variables(0)'
        % Occurences of current dates of variables.
        occur = occur(This.tzero,This.nametype <= 2);
        [Time,Name] = find(occur);
    case 'shocks'
        % Occurences of shocks.
        occur = occur(This.tzero,:);
        occur(:,This.nametype ~= 3) = false;
        [Time,Name] = find(occur);
    case 'parameters'
        % Occurences of parameters.
        occur = occur(This.tzero,:);
        occur(:,This.nametype ~= 4) = false;
        [Time,Name] = find(occur);
    otherwise
        Time = zeros(1,0);
        Name = zeros(1,0);
end

end