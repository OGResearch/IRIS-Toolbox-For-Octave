function [Flag,Inx] = chk(This,IAlt,varargin)
% chk  [Not a public function] Check for missing or inconsistent values assigned within the model object.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isequal(IAlt,Inf)
    IAlt = 1 : size(This.Assign,3);
end

for i = 1 : length(varargin)
    switch varargin{i}
        case 'log'
            realsmall = getrealsmall();
            Inx = find(This.log);
            Inx = Inx(any(This.Assign(1,Inx,IAlt) <= realsmall,3));
            Flag = isempty(Inx);
            if ~Flag
                utils.warning('model',...
                    ['This log-linear variable ', ...
                    'has (numerically) non-positive steady state: ''%s''.'], ...
                    This.name{Inx});
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
