function [GR,FIG,AX,LN] = plotcmpsstate(m0,m,parname,list,varargin)
% plotcmpsstate  Visualise steady-state comparative static.
%
% Syntax
% =======
%
%     [GR,FIG,AX,LN] = grfun.plotcmpsstate(M0,M,PARNAME,expr,...)
%
% Input arguments
% ================
%
% Output arguments
% =================
%
% Options
% ========
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

def = { ...
    'xlabel','',@ischar, ...
    'ylabel','',@ischar, ...
    'style',[],@(x) isempty(x) || isstruct(x), ...
    'tight',true,@islogicalscalar, ...
    'vline',true,@islogicalscalar, ...
    'zeroline',true,@islogicalscalar, ...
    };

opt = passvalopt(def,varargin{:});

%**************************************************************************

% names = [get(m0,'ylist'),get(m0,'xlist')];
% logs = [get(m0,'ylog'),get(m0,'xlog')];
ss0 = get(m0,'sstatelevel');
ss = get(m,'sstatelevel');

x0 = m0.(parname);
x = m.(parname);
nlist = length(list);
GR = cell(1,nlist);

% Check for the first character in the expression. The stars '*' and plus
% signs '+' indicate multiplicative or additive treatment.
type = cell(1,nlist);
for i = 1 : nlist
    type{i} = '*';
    if isempty(list{i})
        continue
    elseif strncmp(list{i},'+',1)
        type{i} = '+';
        list{i}(1) = '';
    elseif strncmp(list{i},'*',1);
        type{i} = '*';
        list{i} = '';
    end
end

% Get expressions and labels.
[expr,tit] = preparser.labeledexpr(list);
empty = cellfun(@isempty,tit);
tit(empty) = expr(empty);
isvar = cellfun(@isvarname,expr);

% Vectorise s/s expressions.
expr(~isvar) = strfun.vectorise(expr(~isvar));

% Cycle over expressions to evaluate them.
for i = 1 : nlist
    if isvarname(i)
        y0 = ss0.(expr{i});
        y = ss.(expr{i});
    else
        y0 = dbeval(ss0,expr{i});
        y = dbeval(ss,expr{i});
    end
    GR{i}{1} = x;
    switch type{i}
        case '*'
            GR{i}{2} = 100*(y/y0 - 1);
        case '+'
            GR{i}{2} = y - y0;
    end
end

% Plot the comparative statics.
FIG = grfun.nextplot(nlist);
AX = [];
LN = [];
for i = 1 : nlist
    AX(end+1) = grfun.nextplot(); %#ok<AGROW>
    try %#ok<TRYNC>
        LN(end+1) = plot(GR{i}{:}); %#ok<AGROW>
    end
    grid('on');
    axis('tight');
    if ~isempty(opt.xlabel)
        xlabel(opt.xlabel);
    end
    if ~isempty(opt.ylabel)
        ylabel(opt.ylabel);
    end
    if opt.zeroline
        grfun.zeroline(AX(end));
    end
    if opt.vline
        grfun.vline(AX(end),x0);
    end
    tit{i} = strrep(tit{i},'\\',sprintf('\n'));    
    title(tit{i});
end

if ~isempty(opt.style)
    qstyle(FIG,opt.style);
end

end