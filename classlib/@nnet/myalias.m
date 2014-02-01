function Query = myalias(Query)
% myalias  [Not a public function] Aliasing get and set queries for getsetobj subclasses.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Alias param, params, parameter, parameters.
Query = regexprep(Query,'param.*','param') ;

% Alias nalt, nalter.
Query = regexprep(Query,'nalt(er)?','nalt') ;

end