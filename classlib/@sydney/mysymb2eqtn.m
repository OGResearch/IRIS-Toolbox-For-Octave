function Eqtn = mysymb2eqtn(Eqtn,Mode)
% mysymb2eqtn  [Not a public function] Replace sydney representation of variables back with a variable array.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    Mode; %#ok<VUNUS>
catch
    Mode = 'full';
end

%--------------------------------------------------------------------------

% Replace xN, xNpK, or xNmK back with x(:,N,t+/-K).
% Replace Ln back with L(:,n).

% Make sure we only replace whole words not followed by an opening round
% bracket to avoid conflicts with function names.

switch Mode
    
    case 'full'
        Eqtn = regexprep(Eqtn, ...
            '\<([xL])(\d+)p(\d+)\>(?!\()', '$1(:,$2,t+$3)' );
        Eqtn = regexprep(Eqtn, ...
            '\<([xL])(\d+)m(\d+)\>(?!\()', '$1(:,$2,t-$3)' );
        Eqtn = regexprep(Eqtn, ...
            '\<([xL])(\d+)\>(?!\()', '$1(:,$2,t)' );
        Eqtn = regexprep(Eqtn, ...
            '\<g(\d+)\>(?!\()', 'g($1,:)' );
        
    case 'sstate'
        % Leave lags and leads in sstate equations *semifinished*.
        Eqtn = regexprep(Eqtn, ...
            '\<[xL](\d+)p(\d+)\>(?!\()', '%($1){+$2}' );
        Eqtn = regexprep(Eqtn, ...
            '\<[xL](\d+)m(\d+)\>(?!\()', '%($1){-$2}' );
        Eqtn = regexprep(Eqtn, ...
            '\<[xL](\d+)\>(?!\()', '%($1)' );
        Eqtn = regexprep(Eqtn, ...
            '\<g(\d+)\>(?!\()', 'NaN' );        
        Eqtn = strrep(Eqtn,'%(','x(');
end

end