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
    TVec = This.Shift;
end

%--------------------------------------------------------------------------

realexp = @(x) real(exp(x));
nAlt = size(This.Assign,3);
nPer = length(TVec);
nId = length(Id);

realId = real(Id);
imagId = imag(Id);
ixLog = This.IxLog(realId);
rep = ones(1,nPer);
sh = imagId(:);
sh = sh(:,rep);
sh = sh + TVec(ones(1,nId),:);

if isequal(ILoop,Inf)
    X = zeros(nId,nPer,nAlt);
    for ILoop = 1 : nAlt
        X(:,:,ILoop) = doOneTrendArray();
    end
else
    X = doOneTrendArray();
end


% Nested functions...


%**************************************************************************


    function X = doOneTrendArray()
            lvl = real(This.Assign(1,realId,min(ILoop,end)));
            grw = imag(This.Assign(1,realId,min(ILoop,end)));
            
            % Zero or no imag means zero growth also for log variables.
            grw(ixLog & grw == 0) = 1;
            
            ixGrw = (~ixLog & grw ~= 0) | (ixLog & grw ~= 1);
            
            % Level can be negative and log(level) complex for log variables; growth
            % must be positive for log variables.
            lvl(ixLog) = log(lvl(ixLog));
            grw(ixLog) = reallog(grw(ixLog));
            
            lvl = lvl.';
            grw = grw.';
            
            X = lvl(:,rep);
            if any(ixGrw)
                X(ixGrw,:) = X(ixGrw,:) ...
                    + sh(ixGrw,:).*grw(ixGrw,rep);
            end
            
            % Delog only if requested.
            if IsDelog
                X(ixLog,:) = realexp(X(ixLog,:));
            end
    end % doOneTrendArray()


end
