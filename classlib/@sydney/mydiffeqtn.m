function DEqtn = mydiffeqtn(Eqtn,Mode,NmOcc,TmOcc)
% mydiffeqtn  [Not a public function] Differentiate one equation wrt to a list of names.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if isempty(TmOcc)
    TmOcc = zeros(size(NmOcc));
end

%--------------------------------------------------------------------------

% Remove anonymous function preamble.
Eqtn = regexprep(char(Eqtn),'^@\(.*?\)','','once');

% Replace x(:,n,t+k) with xN, xNpK, or xNmK.
Eqtn = sydney.myeqtn2symb(Eqtn);

nocc = length(NmOcc);
unknown = cell(1,nocc);
for i = 1 : nocc
    if TmOcc(i) == 0
        % Time index == 0: replace x(1,23,t) with x23.
        unknown{i} = sprintf('x%g',NmOcc(i));
    elseif TmOcc(i) > 0
        % Time index > 0: replace x(1,23,t+1) with x23p1.
        unknown{i} = sprintf('x%gp%g',NmOcc(i),round(TmOcc(i)));
    else
        % Time index < 0: replace x(1,23,t-1) with x23m1.
        unknown{i} = sprintf('x%gm%g',NmOcc(i),round(abs(TmOcc(i))));
    end
end

% Create sydney object for the current equation.
Z = sydney(Eqtn,unknown);

switch Mode
    case 'enbloc'
        % Differentiate and reduce the result. The function returned by sydney.diff
        % computes derivatives wrt all variables at once, and returns a vector of
        % numbers.
        Z = diff(Z,'enbloc',unknown);
        DEqtn = char(Z);
    case 'separate'
        % Derivatives wrt individual names are computed and stored separately.
        DEqtn = cell(1,nocc);
        if nocc > 0
            Z = diff(Z,'separate',unknown);
            for i = 1 : nocc
                DEqtn{i} = char(Z{i});
            end
        end
    otherwise
        utils.error('sydney:mydiffeqtn', ...
            'Invalid output mode');
end

% Replace xN, xNpK, xNmK back with x(:,N,t+/-K).
% Replace LN, LNpK, LNmK back with L(:,n,t+/-K).
DEqtn = sydney.mysymb2eqtn(DEqtn);

end