function X = mytrendarray(This,ILoop,IsDelog,Id,TVec)
% mytrendarray  [Not a public function] Create array with steady state paths for all variables.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    ILoop;
catch
    ILoop = Inf;
end

try
    IsDelog;
catch
    IsDelog = true;
end

try
    Id; %#ok<VUNUS>
catch
    Id = 1 : length(This.name);
end

try
    TVec; %#ok<VUNUS>
catch
    nt = size(This.occur,2) / length(This.name);
    t = This.tzero;
    minT = 1 - t;
    maxT = nt - t;
    TVec = minT : maxT;
end

%--------------------------------------------------------------------------

nAlt = size(This.Assign,3);
nPer = length(TVec);
nId = length(Id);

realId = real(Id);
imagId = imag(Id);
ixLogPlus = This.LogSign(realId) == 1;
ixLogMinus = This.LogSign(realId) == -1;
repeat = ones(1,nPer);
shift = imagId(:);
shift = shift(:,repeat);
shift = shift + TVec(ones(1,nId),:);

if isequal(ILoop,Inf)
    X = zeros(nId,nPer,nAlt);
    for ILoop = 1 : nAlt
        Xi = doOneTrendArray();
        X(:,:,ILoop) = Xi;
    end
else
    X = doOneTrendArray();
end

% Nested functions...


%**************************************************************************


    function X = doOneTrendArray()
            level = real(This.Assign(1,realId,min(ILoop,end)));
            growth = imag(This.Assign(1,realId,min(ILoop,end)));
            
            % No imaginary part means zero growth for log variables.
            growth(ixLogPlus & growth == 0) = 1;
            growth(ixLogMinus & growth == 0) = 1;
            
            % Use `reallog` to make sure negative numbers throw an error.
            level(ixLogPlus) = reallog(level(ixLogPlus));
            growth(ixLogPlus) = reallog(growth(ixLogPlus));
            level(ixLogMinus) = reallog(-level(ixLogMinus));
            growth(ixLogMinus) = reallog(growth(ixLogMinus));
            
            level = level.';
            growth = growth.';
            
            X = level(:,repeat) + shift.*growth(:,repeat);
            if IsDelog
                X(ixLogPlus,:) = exp(X(ixLogPlus,:));
                X(ixLogMinus,:) = -exp(X(ixLogMinus,:));
            end
    end % doOneTrendArray()


end