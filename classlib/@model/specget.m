function [X,Flag,Query] = specget(This,Query)
% specget  [Not a public function] Implement GET method for model objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Call superclass `specget` first.
[X,Flag,Query] = specget@modelobj(This,Query);

% Call to superclass successful.
if Flag
    return
end

X = [];
Flag = true;

ssLevel = [];
ssGrowth = [];
dtLevel = [];
dtGrowth = [];
level = [];
growth = [];
sstateList = { ...
    'ss','sslevel','level','ssgrowth','growth', ...
    'dt','dtlevel','dtgrowth', ...
    'ss+dt','sslevel+dtlevel','ssgrowth+dtgrowth', ...
    };

% Query relates to steady state.
if any(strcmpi(Query,sstateList))
    [ssLevel,ssGrowth,dtLevel,dtGrowth,level,growth] = xxSstate(This);
end

nx = length(This.solutionid{2});
nb = size(This.solution{1},2);
nf = nx - nb;
nAlt = size(This.Assign,3);

eigValTol = This.Tolerance(1);
realSmall = getrealsmall();

cell2DbaseFunc = @(X) cell2struct( ...
    num2cell(permute(X,[2,3,1]),2), ...
    This.name(:),1);

% Check availability of solution.
chkSolution = false;
addParams = false;

switch Query
    
    case 'ss'
        X = cell2DbaseFunc(ssLevel+1i*ssGrowth);
        % addParams = true;
        
    case 'sslevel'
        X = cell2DbaseFunc(ssLevel);
        addParams = true;
        
    case 'ssgrowth'
        X = cell2DbaseFunc(ssGrowth);
        addParams = true;
        
    case 'dt'
        X = cell2DbaseFunc(dtLevel+1i*dtGrowth);
        addParams = true;
        
    case 'dtlevel'
        X = cell2DbaseFunc(dtLevel);
        addParams = true;
        
    case 'dtgrowth'
        inx = This.nametype == 1;
        X = cell2DbaseFunc(dtGrowth);
        addParams = true;
        
    case 'ss+dt'
        X = cell2DbaseFunc(level+1i*growth);
        addParams = true;
        
    case 'sslevel+dtlevel'
        X = cell2DbaseFunc(level);
        addParams = true;
        
    case 'ssgrowth+dtgrowth'
        X = cell2DbaseFunc(growth);
        addParams = true;
        
    case {'eig','eigval','roots'}
        X = eig(This);
        
    case 'rlist'
        X = {This.outside.lhs{:}};
        
    case {'deqtn'}
        X = This.eqtn(This.eqtntype == 3);
        X(cellfun(@isempty,X)) = [];
        
    case {'leqtn'}
        X = This.eqtn(This.eqtntype == 4);
        
    case 'reqtn'
        n = length(This.outside.rhs);
        X = cell([1,n]);
        for i = 1 : n
            X{i} = sprintf('%s=%s;', ...
                This.outside.lhs{i},This.outside.rhs{i});
        end
        % Remove references to database d from reporting equations.
        X = regexprep(X,'d\.([a-zA-Z])','$1');
        
    case {'neqtn','nonlineqtn'}
        X = This.eqtn(This.nonlin);
        
    case {'nlabel','nonlinlabel'}
        X = This.eqtnlabel(This.nonlin);
        
    case 'rlabel'
        X = This.outside.label;
        
    case 'yvector'
        X = This.solutionvector{1};
        
    case 'xvector'
        X = This.solutionvector{2};
        
    case 'xfvector'
        X = This.solutionvector{2}(1:nf);
        
    case 'xbvector'
        X = This.solutionvector{2}(nf+1:end);
        
    case 'evector'
        X = This.solutionvector{3};
        
    case {'ylog','xlog','elog'}
        inx = find(Query(1) == 'yxe');
        X = This.log(This.nametype == inx);
        
    case 'yid'
        X = This.solutionid{1};
        
    case 'xid'
        X = This.solutionid{2};
        
    case 'eid'
        X = This.solutionid{3};
        
    case {'eylist','exlist'}
        t = This.tzero;
        nname = length(This.name);
        inx = nname*(t-1) + find(This.nametype == 3);
        eyoccur = This.occur(This.eqtntype == 1,inx);
        exoccur = This.occur(This.eqtntype == 2,inx);
        eyindex = any(eyoccur,1);
        exindex = any(exoccur,1);        
        elist = This.name(This.nametype == 3);
        if Query(2) == 'y'
            X = elist(eyindex);
        else
            X = elist(exindex);
        end

    case {'derivatives','xderivatives','yderivatives'}
        doDerivatives();
        
    case {'wrt','xwrt','ywrt'}
        doWrt();
        
    case {'dlabel','llabel'}
        type = find(Query(1) == 'xydl');
        X = This.eqtnlabel(This.eqtntype == type);

    case {'deqtnalias','leqtnalias'}
        type = find(Query(1) == 'xydl');
        X = This.eqtnalias(This.eqtntype == type);
        
    case 'link'
        X = cell2struct(This.eqtn(This.eqtntype == 4), ...
            This.name(This.Refresh),2);
        
    case {'diffuse','nonstationary','stationary', ...
            'stationarylist','nonstationarylist'}
        doStationary();
        
    case 'maxlag'
        X = min(imag(This.systemid{2}));
        
    case 'maxlead'
        X = max(imag(This.systemid{2})) + 1;
        
    case {'icond','initcond','required'}
        % List of intial conditions required at least for one parameterisation.
        id = This.solutionid{2}(nf+1:end);
        inx = any(This.icondix,3);
        id = id(inx) - 1i;
        X = myvector(This,id);
        
    case {'forward'}
        ne = sum(This.nametype == 3);
        X = size(This.solution{2},2)/ne - 1;
        chkSolution = true;
        
    case {'stableroots','unitroots','unstableroots'}
        switch Query
            case 'stableroots'
                inx = abs(This.eigval) < (1 - eigValTol);
            case 'unstableroots'
                inx = abs(This.eigval) > (1 + eigValTol);
            case 'unitroots'
                inx = abs(abs(This.eigval) - 1) <= eigValTol;
        end
        X = nan(size(This.eigval));
        for iAlt = 1 : nAlt
            n = sum(inx(1,:,iAlt));
            X(1,1:n,iAlt) = This.eigval(1,inx(1,:,iAlt),iAlt);
        end
        X(:,all(isnan(X),3),:) = [];
        
    case 'epsilon'
        X = This.epsilon;
        
    case 'userdata'
        X = userdata(This);
        
    % Database of autoexogenise definitions d.variable = 'shock';
    case {'autoexogenise','autoexogenised','autoexogenize','autoexogenized'}
        X = autoexogenise(This);
        
    case {'activeshocks','inactiveshocks'}
        X = cell([1,nAlt]);
        for iAlt = 1 : nAlt
            list = This.name(This.nametype == 3);
            stdvec = This.Assign(1, ...
                end-sum(This.nametype == 3)+1:end,iAlt);
            if Query(1) == 'a'
                list(stdvec == 0) = [];
            else
                list(stdvec ~= 0) = [];
            end
            X{iAlt} = list;
        end
        
    case 'nx'
        X = length(This.solutionid{2});
    case 'nb'
        X = size(This.solution{7},1);
    case 'nf'
        X = length(This.solutionid{2}) - size(This.solution{7},1);
    case 'ny'
        X = length(This.solutionid{1});
    case 'ne'
        X = length(This.solutionid{3});
        
    case 'lastsyst'
        X = This.lastSyst;
        
    otherwise
        Flag = false;
        
end

if chkSolution
    % Report solution(s) not available.
    [solutionFlag,inx] = isnan(This,'solution');
    if solutionFlag
        utils.warning('model', ...
            'Solution(s) not available %s', ...
            preparser.alt2str(inx));
    end
end

% Add parameters, std devs and non-zero cross-corrs.
if addParams
    X = addparam(This,X);
end

% Nested functions.

%**************************************************************************
    function doStationary()
        chkSolution = true;
        id = [This.solutionid{1:2}];
        t0 = imag(id) == 0;
        name = This.name(real(id(t0)));
        [~,inx] = isnan(This,'solution');
        status = nan([sum(t0),nAlt]);
        for iialt = find(~inx)
            unit = abs(abs(This.eigval(1,1:nb,iialt)) - 1) <= eigValTol;
            dy = any(abs(This.solution{4}(:,unit,iialt)) > realSmall,2).';
            df = any(abs(This.solution{1}(1:nf,unit,iialt)) > realSmall,2).';
            db = any(abs(This.solution{7}(:,unit,iialt)) > realSmall,2).';
            d = [dy,df,db];
            if strncmp(Query,'s',1)
                % Stationary.
                status(:,iialt) = transpose(double(~d(t0)));
            else
                % Non-stationary.
                status(:,iialt) = transpose(double(d(t0)));
            end
        end
        try %#ok<TRYNC>
            status = logical(status);
        end
        if ~isempty(strfind(Query,'list'))
            % List.
            if nAlt == 1
                X = name(status == true | status == 1);
                X = X(:)';
            else
                X = cell([1,nAlt]);
                for ii = 1 : nAlt
                    X{ii} = name(status(:,ii) == true | status(:,ii) == 1);
                    X{ii} = X{ii}(:)';
                end
            end
        else
            % Database.
            X = cell2struct(num2cell(status,2),name(:),1);
        end
    end % doStationary().

%**************************************************************************
    function doDerivatives()
        if strncmpi(Query,'y',1)
            select = This.eqtntype == 1;
        elseif strncmpi(Query,'x',1)
            select = This.eqtntype == 2;
        else
            select = This.eqtntype <= 2;
        end
        nEqtn = sum(select);
        X = cell(1,nEqtn);
        for iieq = find(select)
            u = char(This.deqtnF{iieq});
            u = regexprep(u,'^@\(.*?\)','','once');
            replacePlusMinus = @doReplacePlusMinus; %#ok<NASGU>
            replaceZero = @doReplaceZero; %#ok<NASGU>
            u = regexprep(u,'\<x\>\(:,(\d+),t([+\-]\d+)\)', ...
                '${replacePlusMinus($1,$2)}');
            u = regexprep(u,'\<x\>\(:,(\d+),t\)', ...
                '${replaceZero($1)}');
            X{iieq} = u;
        end
        
        function c = doReplacePlusMinus(c1,c2)
            inx = sscanf(c1,'%g');
            c = [This.name{inx},'{',c2,'}'];
        end % doReplacePlusMinus().
        
        function c = doReplaceZero(c1)
            inx = sscanf(c1,'%g');
            c = This.name{inx};
        end % doReplaceZero().
        
    end % doDerivatives().
   
%**************************************************************************
    function doWrt()
        if strncmpi(Query,'y',1)
            select = This.eqtntype == 1;
        elseif strncmpi(Query,'x',1)
            select = This.eqtntype == 2;
        else
            select = This.eqtntype <= 2;
        end        
        neqtn = sum(select);
        X = cell(1,neqtn);
        for iieq = find(select)
            [tmocc,nmocc] = myfindoccur(This,iieq,'variables_shocks');
            tmocc = tmocc - This.tzero;
            nocc = length(tmocc);
            X{iieq} = cell(1,nocc);
            for iiocc = 1 : nocc
                c = This.name{nmocc(iiocc)};
                if tmocc(iiocc) ~= 0
                    c = sprintf('%s{%+g}',c,tmocc(iiocc));
                end
                if This.log(nmocc(iiocc))
                    c = ['log(',c,')']; %#ok<AGROW>
                end
                X{iieq}{iiocc} = c;
            end
        end
    end % doWrt().

end

% Subfunctions.

%**************************************************************************
function [ssLevel,ssGrowth,dtLevel,dtGrowth,ssDtLevel,ssDtGrowth] ...
    = xxSstate(This)

Assign = This.Assign;
isLog = This.log;
ny = sum(This.nametype == 1);
nAlt = size(Assign,3);
nName = size(This.Assign,2);

% Steady states.
ssLevel = real(Assign);
ssGrowth = imag(Assign);

% Fix missing (=zero) growth in steady states of log variables.
ssGrowth(ssGrowth == 0 & isLog(1,:,ones(1,nAlt))) = 1;

% Retrieve dtrends.
[dtLevel,dtGrowth] = mydtrendsrequest(This,'sstate');
dtLevel = permute(dtLevel,[3,1,2]);
dtGrowth = permute(dtGrowth,[3,1,2]);
dtLevel(:,ny+1:nName,:) = 0;
dtGrowth(:,ny+1:nName,:) = 0;
dtLevel(1,~isLog,:) = dtLevel(1,~isLog,:);
dtLevel(1,isLog,:) = exp(dtLevel(1,isLog,:));
dtGrowth(1,~isLog,:) = dtGrowth(1,~isLog,:);
dtGrowth(1,isLog,:) = exp(dtGrowth(1,isLog,:));

% Steady state plus dtrends.
ssDtLevel = ssLevel;
ssDtLevel(1,isLog,:) = ssDtLevel(1,isLog,:) .* dtLevel(1,isLog,:);
ssDtLevel(1,~isLog,:) = ssDtLevel(1,~isLog,:) + dtLevel(1,~isLog,:);
ssDtGrowth = ssGrowth;
ssDtGrowth(1,isLog,:) = ssDtGrowth(1,isLog,:) .* dtGrowth(1,isLog,:);
ssDtGrowth(1,~isLog,:) = ssDtGrowth(1,~isLog,:) + dtGrowth(1,~isLog,:);

end % xxSstate().