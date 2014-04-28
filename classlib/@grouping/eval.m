function [S,L] = eval(This,S,varargin)
% eval  Evaluate contributions in input database S using grouping object G.
%
% Syntax
% =======
%
%     [S,L] = eval(G,S)
%
% Input arguments
% ================
%
% * `G` [ grouping ] - Grouping object.
%
% * `S` [ dbase ] - Input dabase with individual contributions.
%
% Output arguments
% =================
%
% * `S` [ dbase ] - Output database with grouped contributions.
%
% * `L` [ cellstr ] - Legend entries based on the list of group names.
%
% Options
% ========
%
% * `'append='` [ *`true`* | `false` ] - Append in the output database all
% remaining data columns from the input database that do not correspond to
% any contribution of shocks or measurement variables.
%
% Description
% ============
%
% Example
% ========
%
% For a model object `M`, database `D` and simulation range `R`,
%
%     S = simulate(M,D,R,'contributions=',true) ;
%     G = grouping(M)
%     ...
%     G = addgroup(G,GroupName,GroupContents) ;
%     ...
%     S = eval(S,G)
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('S',@isstruct);
pp.addRequired('G',@(x) isa(x,'grouping'));
pp.parse(S,This);

opt = passvalopt('grouping.eval',varargin{:});

isOther = any(This.otherContents);

% Contributions of shocks or measurement variables.
nGroup = numel(This.groupNames) ;
nNewCol = nGroup + double(isOther) ;

% Number of old columns used in grouping; the remaing old columns will
% simply appended to the final data (this includes things like Init+Const,
% Nonlinear, etc.).
nColUsed = length(This.list) ;

varNames = fields(This.logVars) ;
for iVar = 1:numel(varNames)
    
    iName = varNames{iVar};
    
    % Contributions for log variables are multiplicative
    isLog = This.logVars.(iName); 
    if isLog
        meth = @(x) prod(x,2) ;
    else
        meth = @(x) sum(x,2) ;
    end
    
    % Do grouping
    [oldData,range] = rangedata(S.(iName)) ;
    oldCmt = comment(S.(iName));
    nPer = size(oldData,1) ;
    
    newData = nan(nPer,nNewCol) ;
    for iGroup = 1:nGroup
        ind = This.groupContents{iGroup} ;
        newData(:,iGroup) = meth(oldData(:,ind)) ;
    end
    
    % Handle 'Other' group.
    if isOther
        ind = This.otherContents ;
        newData(:,nGroup+1) = meth(oldData(:,ind)) ;
    end
    
    
    % Comment the new tseries() object.
    newCmt = cell(1,nNewCol) ;
    for iGroup = 1:nGroup
        newCmt{iGroup} = ...
            utils.concomment(iName,This.groupNames{iGroup},isLog) ;
    end
    if isOther
        newCmt{nGroup+1} = utils.concomment(iName,This.otherName,isLog) ;
    end
    
    % Append remaining old data and old columns.
    if opt.append
        oldData(:,1:nColUsed) = [] ;
        newData = [newData,oldData] ; %#ok<AGROW>
        oldCmt(:,1:nColUsed) = [] ;
        newCmt = [newCmt,oldCmt] ; %#ok<AGROW>
    end
    
    S.(iName) = replace(S.(iName),newData,range(1),newCmt) ;
end

L = This.groupNames;
if isOther
    L = [L,{This.otherName}];
end

end
