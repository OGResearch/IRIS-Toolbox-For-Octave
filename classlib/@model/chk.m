function Flag = chk(This,IAlt,varargin)
% chk  [Not a public function] Check for missing or inconsistent values assigned within the model object.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isequal(IAlt,Inf)
    IAlt = 1 : size(This.Assign,3);
end

for i = 1 : length(varargin)
    switch varargin{i}
        case 'log'
            realsmall = getrealsmall();
            IxPlus = find(This.LogSign == 1);
            IxPlus = IxPlus(any(This.Assign(1,IxPlus,IAlt) <= realsmall,3));
            Flag = isempty(IxPlus);
            if ~Flag
                utils.warning('model',...
                    ['This log-plus variable ', ...
                    'has (numerically) non-positive steady state: ''%s''.'], ...
                    This.name{IxPlus});
            end
            IxMinus = find(This.LogSign == -1);
            IxMinus = IxMinus(any(This.Assign(1,IxPlus,IAlt) >= realsmall,3));
            Flag = isempty(IxMinus);
            if ~Flag
                utils.warning('model',...
                    ['This log-minus variable ', ...
                    'has (numerically) non-negative steady state: ''%s''.'], ...
                    This.name{IxMinus});
            end
            
        case 'parameters'
            % Throw warning if some parameters are not assigned.
            [Flag,list] = isnan(This,'parameters',IAlt);
            if Flag
                utils.warning('model', ...
                    'This parameter is not assigned: ''%s''.', ...
                    list{:});
            end
        case 'sstate'
            % Throw warning if some steady states are not assigned.
            [Flag,list] = isnan(This,'sstate',IAlt);
            if Flag
                utils.warning('model', ...
                    ['Steady state is not available ', ...
                    'for this variable: ''%s''.'], ...
                    list{:});
            end
    end
end

end
