function Eqtn = mysymb2eqtn(Eqtn)
% mysymb2eqtn  [Not a public function] Replace sydney representation of variables back with a variable array.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Replace xN, xNpK, or xNmK back with x(:,N,t+/-K).
% Replace Ln back with L(:,n).

% Make sure we only replace whole words not followed by an opening round
% bracket to avoid conflicts with function names.

Eqtn = regexprep(Eqtn,'\<x(\d+)p(\d+)\>(?!\()','x(:,$1,t+$2)');
Eqtn = regexprep(Eqtn,'\<x(\d+)m(\d+)\>(?!\()','x(:,$1,t-$2)');
Eqtn = regexprep(Eqtn,'\<x(\d+)\>(?!\()','x(:,$1,t)');
Eqtn = regexprep(Eqtn,'\<L(\d+)\>(?!\()','L(:,$1)');
Eqtn = regexprep(Eqtn,'\<g(\d+)\>(?!\()','g($1,:)');

end