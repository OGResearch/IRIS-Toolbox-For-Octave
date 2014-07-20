function [Time,Name] = myfindoccur(This,Eq,Type)
% myfindoccur  [Not a public function] Find occurences of names in an equation.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

nName = length(This.name);
occur = This.occur(Eq,:);
occur = reshape(occur,[nName,size(This.occur,2)/nName]);
occur = occur.';
t0 = find(This.Shift == 0);

switch Type
    case 'variables_shocks'
        % Occurences of variables and shocks.
        occur = occur(:,This.nametype <= 3);
        [Time,Name] = find(occur);
    case 'variables(0)'
        % Occurences of current dates of variables.
        occur = occur(t0,This.nametype <= 2);
        [Time,Name] = find(occur);
    case 'shocks'
        % Occurences of shocks.
        occur = occur(t0,:);
        occur(:,This.nametype ~= 3) = false;
        [Time,Name] = find(occur);
    case 'parameters'
        % Occurences of parameters.
        occur = occur(t0,:);
        occur(:,This.nametype ~= 4) = false;
        [Time,Name] = find(occur);
    otherwise
        Time = zeros(1,0);
        Name = zeros(1,0);
end

end
