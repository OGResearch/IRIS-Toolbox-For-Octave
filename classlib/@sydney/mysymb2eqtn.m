function Eqtn = mysymb2eqtn(Eqtn,Mode,IsLog)
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
        Eqtn = regexprep(Eqtn,'\<x(\d+)p(\d+)\>(?!\()','x(:,$1,t+$2)');
        Eqtn = regexprep(Eqtn,'\<x(\d+)m(\d+)\>(?!\()','x(:,$1,t-$2)');
        Eqtn = regexprep(Eqtn,'\<x(\d+)\>(?!\()','x(:,$1,t)');
        Eqtn = regexprep(Eqtn,'\<L(\d+)\>(?!\()','L(:,$1)');
        Eqtn = regexprep(Eqtn,'\<g(\d+)\>(?!\()','g($1,:)');
    case 'sstate'
        Eqtn = regexprep(Eqtn, ...
            '\<x(\d+)p(\d+)\>(?!\()','(%($1)+$2*dx($1))');
        Eqtn = regexprep(Eqtn, ...
            '\<x(\d+)m(\d+)\>(?!\()','(%($1)-$2*dx($1))');
        Eqtn = regexprep(Eqtn,'\<x(\d+)\>(?!\()','(%($1))');
        Eqtn = regexprep(Eqtn,'\<L(\d+)\>(?!\()','(%($1))');
        Eqtn = regexprep(Eqtn,'\<g(\d+)\>(?!\()','NaN');
        for i = find(IsLog(:).')
            ptn = ['(%(',sprintf('%g',i)];
            rpl = ['exp(%(',sprintf('%g',i)];
            Eqtn = strrep(Eqtn,ptn,rpl);
        end
        Eqtn = strrep(Eqtn,'%','x');
        Eqtn = strrep(Eqtn,'+1*dx(','+dx(');
        Eqtn = strrep(Eqtn,'-1*dx(','-dx(');
end

end