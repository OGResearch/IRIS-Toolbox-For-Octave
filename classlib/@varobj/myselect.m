function [Inx,Invalid] = myselect(This,Type,Select)
% myselect  [Not a public function] Convert user name selection to a logical index.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

switch lower(Type)
    case 'y'
        list = myynames(This);
    case 'e'
        list = myenames(This);
end

N = length(This.YNames);
Select = Select(:).';
Invalid = {};

if isequal(Select,Inf)
    Inx = true(1,N);
elseif isnumeric(Select)
    Inx = false(1,N);
    Inx(Select) = true;
elseif iscellstr(Select) || ischar(Select)
    if ischar(Select)
        Select = regexp(Select,'\w+','match');
    end
    Inx = false(1,N);
    nSelect = length(Select);
    for i = 1 : nSelect
        cmp = strcmp(list,Select{i});
        if any(cmp)
            Inx = Inx | cmp;
        else
            Invalid{end+1} = Select{i}; %#ok<AGROW>
        end
    end
elseif islogical(Select)
    Inx = Select;
else
    Inx = false(1,N);
end

Inx = Inx(:).';

if length(Inx) > N
    Inx = Inx(1:N);
elseif length(Inx) < N
    Inx(end+1:N) = false;
end

end