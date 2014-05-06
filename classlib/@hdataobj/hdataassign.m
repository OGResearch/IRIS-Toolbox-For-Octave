function hdataassign(This,Obj,varargin)
% hdataassign  [Not a public function] Assign currently processed data to hdataobj.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% hdataassign(HData,Obj,Col,...,Y,X,E,...)

%--------------------------------------------------------------------------

[solId,name] = hdatareq(Obj);
nSolId = length(solId);
Data = varargin(end-nSolId+1:end);
varargin(end-nSolId+1:end) = [];
Pos = varargin;

for i = 1 : length(solId)
    
    if isempty(Data{i})
        continue
    end
    
    X = Data{i};
    nPer = size(X,2);
    
    if This.IsStd
        X = xxVar2Std(X);
    end
    
    realId = real(solId{i});
    imagId = imag(solId{i});
    maxLag = -min(imagId);
    % Each variable has been allocated an (nPer+maxLag)-by-nCol array. Get
    % pre-sample data from auxiliary lags.
    if This.IsPreSample && maxLag > 0
        for j = find(imagId < 0)
            jLag = -imagId(j);
            jName = name{realId(j)};
            This.data.(jName)(maxLag+1-jLag,Pos{:}) = ...
                permute(X(j,1,:),[2,3,1]);
        end
    end
    % Current-dated assignments.
    t = maxLag + (1 : nPer);
    for j = find(imagId == 0)
        jName = name{realId(j)};
        jData = This.data.(jName);
        jx = X(j,:,:);
        jData(t,Pos{:}) = permute(jx,[2,3,1]);
        This.data.(jName) = jData;
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