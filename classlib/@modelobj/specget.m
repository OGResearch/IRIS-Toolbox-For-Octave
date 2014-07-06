function [X,Flag,Query] = specget(This,Query)
% specget  [Not a public function] GET method for modelobj objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

X = [];
Flag = true;

nAlt = size(This.Assign,3);
ne = sum(This.nametype == 3);

switch Query
    
    case 'file'
        X = This.fname;
        
    case {'carryon','carryaround','export'}
        X = This.Export;
        
    case {'name','list'}
        X = This.name;
        
    case {'ylist','xlist','elist','plist','glist'}
        type = find(Query(1) == 'yxepg');
        X = This.name(This.nametype == type);
        
    case {'ydescript','xdescript','edescript','pdescript','gdescript'}
        inx = find(Query(1) == 'yxepg');
        X = This.namelabel(This.nametype == inx);

    case {'yalias','xalias','ealias','palias','galias'}
        inx = find(Query(1) == 'yxepg');
        X = This.namealias(This.nametype == inx);
        
    case 'descript'
        X = cell2struct(This.namelabel,This.name,2);

    case 'alias'
        X = cell2struct(This.namealias,This.name,2);
        
    case 'param'
        X = xxGetParam(This);
        
    case 'std'
        [~,~,X] = xxGetStd(This);
        
    case {'corr','nonzerocorr'}
        [~,~,X] = xxGetCorr(This,Query);
        
    case 'stdlist'
        elist = This.name(This.nametype == 3);
        if is.matlab % ##### MOSW
            X = regexprep(elist,'^.','std_$0','once');
        else
            X = strcat('std_',elist);
        end
        
    case 'corrlist'
        X = mycorrnames(This);
        
    case 'stdcorrlist'
        elist = This.name(This.nametype == 3);
        if is.matlab % ##### MOSW
            X = regexprep(elist,'^.','std_$0','once');
        else
            X = strcat('std_',elist);
        end
        X = [X,mycorrnames(This)];
        
    case {'log','islog'}
        X = struct();
        for iType = find(This.nametype <= 3);
            X.(This.name{iType}) = This.log(iType);
        end
        
    case {'loglist'}
        X = This.name(This.log & This.nametype <= 3);
        
    case {'nonloglist'}
        X = This.name(~This.log & This.nametype <= 3);
        
    case {'covmat','omega'}
        X = omega(This);
        
    case {'stdvec'}
        X = permute(This.stdcorr(1,1:ne,:),[2,3,1]);
        
    case {'stdcorrvec'}
        X = permute(This.stdcorr,[2,3,1]);
        
    case {'nalt'}
        X = nAlt;
        
    case {'nametype'}
        X = This.nametype;
                
    case {'torigin','baseyear'}
        X = This.BaseYear;
        if isempty(X)
            X = irisget('baseYear');
        end
        
    case 'build'
        X = This.build;

    % Equations
    %-----------
    
    case {'eqtn'}
        maxType = max(This.eqtntype);
        X = cell(1,maxType);
        for iType = 1 : maxType
            X{iType} = This.eqtn(This.eqtntype == iType);
        end
        
    case {'yeqtn','xeqtn'}
        type = find(Query(1) == 'yx');
        X = This.eqtn(This.eqtntype == type);
                
    % Equation labels and aliases
    %-----------------------------

    case {'label','eqtnalias'}
        if strcmp(Query,'label')
            prop = 'eqtnlabel';
        else
            prop = 'eqtnalias';
        end
        X = This.(prop);

    case {'xlabel','ylabel'}
        type = find(Query(1) == 'yx');
        X = This.eqtnlabel(This.eqtntype == type);

    case {'xeqtnalias','yeqtnalias'}
        type = find(Query(1) == 'yx');
        X = This.eqtnalias(This.eqtntype == type);
        
    otherwise
        Flag = false;
        
end

end


% Subfunctions...


%**************************************************************************
function [List,Values,X] = xxGetStd(This)

ne = sum(This.nametype == 3);
Values = This.stdcorr(1,1:ne,:);
List = This.name(This.nametype == 3);
if is.matlab % ##### MOSW
    List = regexprep(List,'^.','std_$0','once');
else
    List = strcat('std_',List);
end
if nargout > 2
    X = xxNum2Struct(Values,List);
end

end % xxGetStd()


%**************************************************************************
function [List,Values,X] = xxGetCorr(This,Query)

ne = sum(This.nametype == 3);
nAlt = size(This.Assign,3);
if ne > 0
  pos = tril(ones(ne),-1) == 1;
else
  pos = [];  
end
R = zeros(ne,ne,nAlt);
for ialt = 1 : nAlt
    temp = zeros(ne);
    temp(pos) = This.stdcorr(1,ne+1:end,ialt);
    R(:,:,ialt) = temp;
end
if isequal(Query,'nonzerocorr')
    [i,j] = find(any(R ~= 0,3));
else
    [i,j] = find(pos);
end
eList = This.name(This.nametype == 3);
X = struct();
ni = length(i);
List = cell(1,ni);
Values = zeros(1,ni,nAlt);
for k = 1 : length(i)
    name = ['corr_',eList{j(k)},'__',eList{i(k)}];
    List{k} = name;
    Values(1,k,:) = R(i(k),j(k),:);
    X.(name) = permute(R(i(k),j(k),:),[2,3,1]);
end

end % xxGetCorr()


%**************************************************************************
function X = xxGetParam(This)

assign = This.Assign(1,This.nametype == 4,:);
assignlist = This.name(This.nametype == 4);
[stdList,std] = xxGetStd(This);
[corrList,corr] = xxGetCorr(This,'nonzerocorr');
X = xxNum2Struct([assign,std,corr],[assignlist,stdList,corrList]);

end % xxGetParam()


%**************************************************************************
function S = xxNum2Struct(X,List)

S = cell2struct( ...
    num2cell(permute(X,[2,3,1]),2), ...
    List(:),1);

end % xxNum2Struct()
