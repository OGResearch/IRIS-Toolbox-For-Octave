function S0 = groupcont(S,G)
% groupcont  Group contributions in database S using group object G.
%
% Syntax
% =======
%
%     S = groupcont(S,G)
%
% Input arguments
% ================
%
% * `S` [ dbase ] - Database object.
%
% * `G` [ group ] - Group object.
%
% Output arguments
% =================
%
% * `S` [ dbase ] - Database object.
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
%     G = group(M)
%     ...
%     G = addgroup(G,GroupName,GroupContents) ;
%     ...
%     S = groupcont(S,G)

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('S',@isstruct);
pp.addRequired('G',@(x) isa(x,'group'));
pp.parse(S,G);

% Contributions of shocks or measurement variables?
switch G.type
    case 'shock'
        thisList = G.eList ;
    case 'measurement'
        thisList = G.yList ;
end
nGroup = numel(G.groupNames) ;

S0 = struct() ;
varNames = fields(G.logVars) ;
for iVar = 1:numel(varNames)
    % Contributions for log variables are multiplicative
    if G.logVars.(varNames{iVar})
        meth = @(x) prod(x,2) ;
        val = 1 ;
    else
        meth = @(x) sum(x,2) ;
        val = 0 ;
    end
    
    % Do grouping
    vrange = range(S.(varNames{iVar})) ;
    S0.(varNames{iVar}) = tseries(vrange,repmat(val,numel(vrange),numel(G.groupContents)+2)) ;
    for iGroup = 1:nGroup
        for iCont = 1:numel(G.groupContents{iGroup})
            ind = strcmp(thisList,G.groupContents{iGroup}{iCont}) ;
            S0.(varNames{iVar})(:,iGroup) = meth([S0.(varNames{iVar}){:,iGroup},S.(varNames{iVar}){:,ind}]) ;
        end
    end
    
    % Handle 'Other' group
    if ~isempty(G.otherGroup)
        for iCont = 1:numel(G.otherGroup)
            ind = strcmp(thisList,G.otherGroup{iCont}) ;
            S0.(varNames{iVar})(:,iGroup+1) = meth([S0.(varNames{iVar}){:,iGroup},S.(varNames{iVar}){:,ind}]) ;
        end
    end
    
    % Handle 'Init + Const' group (cannot be grouped or removed)
    S0.(varNames{iVar})(:,iGroup+2) = S.(varNames{iVar}){:,end} ;
    
    % Comment tseries() object
    txt = cell(1,nGroup+2) ;
    for iGroup = 1:nGroup
        txt{iGroup} = sprintf('%s <--[+] %s',varNames{iVar},G.groupNames{iGroup}) ;
    end
    if ~isempty(G.otherGroup)
        iGroup = iGroup + 1 ;
        txt{iGroup} = sprintf('%s <--[+] %s',varNames{iVar},'Other') ;
    end
    iGroup = iGroup + 1 ;
    txt{iGroup} = sprintf('%s <--[+] %s',varNames{iVar},'Init + Const') ;
    
    % Delete unnecessary columns
    txt = txt(1:iGroup) ;
    S0.(varNames{iVar}) = S0.(varNames{iVar}){:,1:iGroup} ;
    
    % Finish comments
    S0.( varNames{iVar} ) = comment( S0.( varNames{iVar} ), txt) ;
end

end


