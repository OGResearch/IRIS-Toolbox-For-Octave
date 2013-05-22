function X = mytrendarray(This,Id,TVec,Delog,iAlt)
% mytrendarray  [Not a public function] Create array with steady state paths for all variables.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.


% Note that `iAlt` is allowed to be greater that `nAlt`.
try
    iAlt;
catch %#ok<CTCH>
    iAlt = Inf;
end

%--------------------------------------------------------------------------

nAlt = size(This.Assign,3);
nPer = length(TVec);
nId = length(Id);

realid = real(Id);
imagid = imag(Id);
logInx = This.log(realid);
repeat = ones(1,nPer);
shift = imagid(:);
shift = shift(:,repeat);
shift = shift + TVec(ones(1,nId),:);

if isequal(iAlt,Inf)
    X = zeros(nId,nPer,nAlt);
    for iAlt = 1 : nAlt
        Xi = doOneTrendArray();
        X(:,:,iAlt) = Xi;
    end
else
    X = doOneTrendArray();
end

% Nested functions.

%**************************************************************************
    function X = doOneTrendArray()
        
            level = real(This.Assign(1,realid,min(iAlt,end)));
            growth = imag(This.Assign(1,realid,min(iAlt,end)));
            
            % No imaginary part means zero growth for log variables.
            growth(logInx & growth == 0) = 1;
            
            % Use `reallog` to make sure negative numbers throw an error.
            level(logInx) = reallog(level(logInx));
            growth(logInx) = reallog(growth(logInx));
            
            level = level.';
            growth = growth.';
            
            X = level(:,repeat) + shift.*growth(:,repeat);
            if Delog
                X(logInx,:) = exp(X(logInx,:));
            end
        
    end % doOneTrendArray().

end