function hdataassign(This,Pos,Data)
% hdataassign  [Not a public function] Assign currently processed data to hdataobj.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% hdataassign(HData, Col , {Y,X,E,...} )
% hdataassign(HData, {Col,...} , {Y,X,E,...} )

if ~iscell(Pos)
    Pos = {Pos};
end

%--------------------------------------------------------------------------

nPack = length(This.Id);
nData = length(Data);

for i = 1 : min(nPack,nData)
    
    if isempty(Data{i})
        continue
    end
    
    X = Data{i};
    nPer = size(X,2);
    
    if This.IsVar2Std
        X = xxVar2Std(X);
    end
    
    realId = real(This.Id{i});
    imagId = imag(This.Id{i});
    maxLag = -min(imagId);
    % Each variable has been allocated an (nPer+maxLag)-by-nCol array. Get
    % pre-sample data from auxiliary lags.
    if This.IncludeLag && maxLag > 0
        for j = find(imagId < 0)
            jLag = -imagId(j);
            jName = This.Name{realId(j)};
            This.Data.(jName)(maxLag+1-jLag,Pos{:}) = ...
                permute(X(j,1,:),[2,3,1]);
        end
    end
    % Current-dated assignments.
    t = maxLag + (1 : nPer);
    for j = find(imagId == 0)
        jName = This.Name{realId(j)};
        jData = This.Data.(jName);
        jx = X(j,:,:);
        jData(t,Pos{:}) = permute(jx,[2,3,1]);
        This.Data.(jName) = jData;
    end
    
end

end


% Subfunctions...


%**************************************************************************


function D = xxVar2Std(D)
% xxVar2Std  Convert vectors of vars to vectors of stdevs.
if isempty(D)
    return
end
tol = 1e-15;
inx = D < tol;
if any(inx(:))
    D(inx) = 0;
end
D = sqrt(D);
end % xxVar2Std()
