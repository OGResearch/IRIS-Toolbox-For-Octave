function Def = likfunc()
% likfunc  [Not a public function] Default options for likfunc class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def = struct();

Def.likfunc = { ...
    'comment','',@ischar, ...
    'form','',@(x) any(strcmpi({'','log','-log'},strrep(x,' ',''))), ...
    'userdata',[],@(x) true, ...
    };

% Combine model/estimate with estimateobj/myestimate.
estimateobj = irisopt.estimateobj();
Def.estimate = [ ...
    estimateobj.myestimate, { ...
    }];

end