function DEqtn = mydiffeqtn(Eqtn,Mode,NmOcc,TmOcc,Log,varargin)
% mydiffeqtn  [Not a public function] Differentiate one equation wrt to a list of names.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if isempty(TmOcc)
    TmOcc = zeros(size(NmOcc));
end

if isempty(Log)
    Log = false(1,max(NmOcc));
end

isBsx = any(strcmp(varargin,'bsx'));

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
        DEqtn = char(Z,varargin{:});
        % Multiply derivatives wrt log(X) by X.
        if any(Log(NmOcc))
            c = unknown;
            if ~isBsx
                c(~Log(NmOcc)) = {'1'};
            else
                c(~Log(NmOcc)) = {'ones(1,1,length(t))'};
            end
            c = sprintf('%s;',c{:});
            c(end) = '';
            if ~isBsx
                DEqtn = ['(',DEqtn,').*[',c,']'];
            else
                DEqtn = ['bsxfun(@times,',DEqtn,',[',c,'])'];
            end
        end
    case 'separate'
        % Derivatives wrt individual names are computed and stored separately.
        DEqtn = cell(1,nocc);
        if nocc > 0
            Z = diff(Z,'separate',unknown);
            for i = 1 : nocc
                DEqtn{i} = char(Z{i},varargin{:});
            end
        end
    otherwise
        utils.error('sydney:mydiffeqtn', ...
            'Invalid output mode');
end

% Replace xN, xNpK, or xNmK back with x(:,N,t+/-K).
% Replace Ln back with L(:,n).
DEqtn = sydney.mysymb2eqtn(DEqtn);

end