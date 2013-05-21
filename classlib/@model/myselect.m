function Inx = myselect(This,Type,Select)
% myselect  [Not a public function] Convert user selection to a logical index.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

switch lower(Type)
    case 'y'
        type = 1;
        typeString = 'measurement variable';
    case 'x'
        type = 2;
        typeString = 'transition variable';
    case 'e'
        type = 3;
        typeString = 'shock';
    case 'p'
        type = 4;
        typeString = 'parameter';
end
n = sum(This.nametype == type);

if isempty(Select)
    Inx = false(n,1);
elseif islogical(Select)
    Inx = Select(:);
    if length(Inx) < n
        Inx(end+1:n) = false;
    elseif length(Inx) > n
        Inx = Inx(1:n);
    end
elseif ~isempty(Select) && (ischar(Select) || iscellstr(Select))
    pos = [];
    if ischar(Select)
        Select = regexp(Select,'\w+','match');
    end
    Select = regexprep(Select,'log\((.*?)\)','$1');
    if iscellstr(Select)
        [pos,notFound] = strfun.findnames( ...
            This.name(This.nametype == type), ...
            Select(:)');
        if any(isnan(pos))
            utils.error('model', ...
                ['This is not a valid ',typeString,' name ', ...
                'in the model object: ''%s''.'], ...
                notFound{:});
        end
    end
    Inx = false(n,1);
    Inx(pos) = true;
end

end