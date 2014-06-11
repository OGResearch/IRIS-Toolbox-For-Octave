function sstatefile(This,File,varargin)
% sstatefile  Create a steady-state file based on the model object's steady-state equations.
%
% Syntax
% =======
%
%     sstatefile(m,filename,...)
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object.
%
% * `file` [ char ] - Filename under which the steady-state file will be
% saved.
%
% Options
% ========
%
% * `'endogenise='` [ cellstr | char | *empty* ] - List of parameters that
% will be endogenised when computing the steady state; the number of
% endogenised parameters must match the number of transtion
% variables exogenised in the `'exogenised='` option.
%
% * `'endogenise='` [ cellstr | char | *empty* ] - List of transition
% variables that will be exogenised when computing the steady state; the
% number of exogenised variables must match the number of parameters
% exogenised in the `'exogenise='` option.
%
% * `'growthNames='` [ char | *`'d?'`* ] - Template for growth names used in
% evaluating lags and leads.
%
% * `'time='` [ *`true`* | `false` ] - Keep or remove time subscripts
% (curly braces) in the steady-state file.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

options = passvalopt('model.sstatefile',varargin{:});

%--------------------------------------------------------------------------

if ~isempty(options.endogenise) || ~isempty(options.exogenise)
    % Extract the subsstate object and swap user-requested parameters and
    % transition variables.
    % this = subsstate(this);
    This = mysstateswap(This,options.endogenise,options.exogenise);
    [nameBlk,eqtnBlk] = blazer(This,false);
else
    if ~isempty(This.NameBlk) && ~isempty(This.EqtnBlk)
        nameBlk = This.NameBlk;
        eqtnBlk = This.EqtnBlk;
    else
        [nameBlk,eqtnBlk] = blazer(This,false);
    end
end

% Occurences of parameters in steady-state equations.
occur4 = any(This.occurS(This.eqtntype <= 2,:),1);
occur4(This.nametype ~= 4) = false;

nl = sprintf('\n');

% Steady-state code.
c = '';

% Growth name template.
c = [c,'!growthnames := ',options.growthnames,';',nl,nl];

% List of input parameters.
c = [c, ...
    '!input',nl, ...
    strfun.cslist(This.name(occur4),'wrap',75,'lead','   '),nl, ...
    ];

eqtn = This.eqtn;
% Use steady-state versions.
eqtn = regexprep(eqtn,'^.*?!!','');
% Remove non-linear earmarks.
eqtn = regexprep(eqtn,'==+','=');
% Remove steady-state references.
eqtn = regexprep(eqtn,'&(\w+)','$1');
if ~options.time
    % Remove time subscripts.
    eqtn = regexprep(eqtn,'\{[\+\-]?\d+\}','');
end

% Remove residuals.
elist = This.name(This.nametype == 3);
for i = 1 : length(elist)
    eqtn = regexprep(eqtn,['\<',elist{i},'\>'],'0');
end

nblk = length(eqtnBlk);
wasAssign = false;
for iblk = 1 : nblk
    neqtn = length(eqtnBlk{iblk});
    ieqtn = eqtnBlk{iblk}(1);
    iname = nameBlk{iblk}(1);
    if neqtn == 1 && xxIsAssign(eqtn{ieqtn},This.name{iname})
        % Assignments.
        if ~wasAssign
            c = [c,nl,'!equations',nl]; %#ok<AGROW>
        end
        c = [c,'   ',eqtn{ieqtn},nl]; %#ok<AGROW>
        wasAssign = true;
    else
        % Equations to be solved.
        c = [c,nl,'!equations',nl]; %#ok<AGROW>
        for j = 1 : neqtn
            ieq = eqtnBlk{iblk}(j);
            c = [c,'   ',eqtn{ieq},nl]; %#ok<AGROW>
        end
        c = [c,'   !solvefor',nl]; %#ok<AGROW>
        thisName = This.name(nameBlk{iblk});
        c = [c,strfun.cslist(thisName,'wrap',75,'lead','   '),nl]; %#ok<AGROW>
        % Log list.
        isLog = This.log(nameBlk{iblk});
        if any(isLog)
            logList = thisName(isLog);
            c = [c,'   !log_variables',nl]; %#ok<AGROW>
            c = [c,strfun.cslist(logList,'wrap',75,'lead','   '),nl]; %#ok<AGROW>
        end
        wasAssign = false;
    end
end

% Replace exp(0) with 1. This is a frequent expression in non-linear models
% because of shocks being set to zero.
c = strrep(c,'exp(0)','1');

char2file(c,File);

end


% Subfunctions...


%**************************************************************************


function flag = xxIsAssign(eqtn,name)
% True if this equation can be cast as an assignment.
tokens = regexp(eqtn,'([^=]*)(.*)','tokens','once');
lhs = tokens{1};
rhs = tokens{2};
if ~isempty(rhs)
    rhs(1) = '';
end
flag = strcmp(lhs,name) ...
    & isempty(regexp(rhs,['\<',name,'\>'],'once'));
end % xxIsAssign()
