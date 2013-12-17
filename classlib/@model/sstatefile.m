function sstatefile(this,file,varargin)
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
% -Copyright (c) 2007-2013 IRIS Solutions Team.

options = passvalopt('model.sstatefile',varargin{:});

%**********************************************************************

if ~isempty(options.endogenise) || ~isempty(options.exogenise)
    % Extract the subsstate object and swap user-requested parameters and
    % transition variables.
    % this = subsstate(this);
    this = mysstateswap(this,options.endogenise,options.exogenise);
    this = myblazer(this);
else
    if isempty(this.nameblk) || isempty(this.eqtnblk)
        this = myblazer(this);
    end
end

% Occurences of parameters in steady-state equations.
occur4 = any(this.occurS(this.eqtntype <= 2,:),1);
occur4(this.nametype ~= 4) = false;

nl = sprintf('\n');

% Steady-state code.
c = '';

% Growth name template.
c = [c,'!growthnames := ',options.growthnames,';',nl,nl];

% List of input parameters.
c = [c, ...
    '!input',nl, ...
    strfun.cslist(this.name(occur4),'wrap',75,'lead','   '),nl, ...
    ];

eqtn = this.eqtn;
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
elist = this.name(this.nametype == 3);
for i = 1 : length(elist)
    eqtn = regexprep(eqtn,['\<',elist{i},'\>'],'0');
end

nblk = length(this.eqtnblk);
wasAssign = false;
for iblk = 1 : nblk
    neqtn = length(this.eqtnblk{iblk});
    ieqtn = this.eqtnblk{iblk}(1);
    iname = this.nameblk{iblk}(1);
    if neqtn == 1 && sub_isassign(eqtn{ieqtn},this.name{iname})
        % Assignments.
        if ~wasAssign
            c = [c,nl,'!equations',nl];
        end
        c = [c,'   ',eqtn{ieqtn},nl];
        wasAssign = true;
    else
        % Equations to be solved.
        c = [c,nl,'!equations',nl];
        for j = 1 : neqtn
            ieq = this.eqtnblk{iblk}(j);
            c = [c,'   ',eqtn{ieq},nl];
        end
        c = [c,'   !solvefor',nl];
        thisName = this.name(this.nameblk{iblk});
        c = [c,strfun.cslist(thisName,'wrap',75,'lead','   '),nl];
        % Log list.
        isLog = this.log(this.nameblk{iblk});
        if any(isLog)
            logList = thisName(isLog);
            c = [c,'   !variables:log',nl];
            c = [c,strfun.cslist(logList,'wrap',75,'lead','   '),nl];
        end
        wasAssign = false;
    end
end

% Replace exp(0) with 1. This is a frequent expression in non-linear models
% because of shocks being set to zero.
c = strrep(c,'exp(0)','1');

char2file(c,file);

end


%**************************************************************************
% True if this equation can be cast as an assignment.
function flag = sub_isassign(eqtn,name)
tokens = regexp(eqtn,'([^=]*)(.*)','tokens','once');
lhs = tokens{1};
rhs = tokens{2};
if ~isempty(rhs)
    rhs(1) = '';
end
flag = strcmp(lhs,name) ...
    & isempty(regexp(rhs,['\<',name,'\>'],'once'));
end
% sub_isassign().