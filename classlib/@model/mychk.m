function Flag = mychk(This,IAlt,varargin)
% mychk  [Not a public function] Check for missing or inconsistent values assigned within the model object.
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
            realSmall = getrealsmall();
            ix = This.IxLog ...
                & any(abs(This.Assign(1,:,IAlt)) <= realSmall,3);
            Flag = any(ix);
            if Flag
                utils.warning('model:chk',...
                    ['Steady state for this log variable ', ...
                    'is numerically close to zero: ''%s''.'], ...
                    This.name{ix});
            end
            
        case 'parameters'
            % Throw warning if some parameters are not assigned.
            [Flag,list] = isnan(This,'parameters',IAlt);
            if Flag
                utils.warning('model:chk', ...
                    'This parameter is not assigned: ''%s''.', ...
                    list{:});
            end
            
        case 'sstate'
            % Throw warning if some steady states are not assigned.
            [Flag,list] = isnan(This,'sstate',IAlt);
            if Flag
                utils.warning('model:chk', ...
                    ['Steady state is not available ', ...
                    'for this variable: ''%s''.'], ...
                    list{:});
            end
            
    end
end

end
