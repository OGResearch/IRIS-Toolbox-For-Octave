function Query = myalias(Query)
% myalias  [Not a public function] Aliasing get and set queries for getsetobj subclasses.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Alias filename, fname -> file.
Query = regexprep(Query,'f(ile)?name','file');
% Alias name, names -> list.
Query = regexprep(Query,'names?$','list');
% Alias comment, comments, tag, tags.
Query = regexprep(Query, ...
    'descriptions?|descripts?|descr?|comments?|tags?|annotations?', ...
    'descript');
% Alias param, params, parameter, parameters.
Query = regexprep(Query,'param.*','param');
% Alias corr, corrs, correlation, correlations
Query = regexprep(Query,'corrs?|correlations?','corr');
% Alias nalt, nalter.
Query = regexprep(Query,'nalt(er)?','nalt');
% Alias equation, equations, eqtn, eqtns.
Query = regexprep(Query,'eqtns?|equations?','eqtn');
% Alias label, labels.
Query = regexprep(Query,'labels','label');

% Alias dtrend, dtrends, dt.
Query = regexprep(Query,'dtrends?','dt');
% Alias ss, sstate, steadystate.
Query = regexprep(Query,'s(teady)?state','ss');
% Alias level, levels.
Query = regexprep(Query,'levels','level');
% Alias link, links.
Query = regexprep(Query,'links','link');
% Alias ss_dt, ss+dt.
Query = regexprep(Query,'_','+');

Query = regexprep(Query,'alias(es)?','alias');

end