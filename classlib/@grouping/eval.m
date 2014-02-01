function [S,L] = eval(This,S)
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
% Description
% ============
%
% Example
% ========
%
% For a model object M, database D and simulation range R,
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

isOther = ~isempty(This.otherContents);

% Contributions of shocks or measurement variables?
nGroup = numel(This.groupNames) ;
nCol = nGroup + double(isOther) + 1;

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
    nPer = size(oldData,1) ;
    newData = nan(nPer,nCol) ;
    for iGroup = 1:nGroup
        ind = This.groupContents{iGroup} ;
        newData(:,iGroup) = meth(oldData(:,ind)) ;
    end
    
    % Handle 'Other' group
    if isOther
        ind = This.otherContents ;
        newData(:,nGroup+1) = meth(oldData(:,ind)) ;
    end
    
    % Handle 'Init + Const' group (cannot be grouped or removed)
    newData(:,end) = oldData(:,end) ;
    
    % Comment tseries() object
    newCmt = cell(1,nCol) ;
    for iGroup = 1:nGroup
        newCmt{iGroup} = ...
            utils.concomment(iName,This.groupNames{iGroup},isLog) ;
    end
    if isOther
        newCmt{nGroup+1} = utils.concomment(iName,This.otherName,isLog) ;
    end
    newCmt{end} = utils.concomment(iName,This.constName,isLog) ;
    
    S.(iName) = replace(S.(iName),newData,range(1),newCmt) ;
end

L = This.groupNames;
if isOther
    L = [L,{This.otherName}];
end
L = [L,{This.constName}];

end
