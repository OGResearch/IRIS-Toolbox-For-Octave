function D = hdata2tseries(This,Obj,Range)
% hdata2tseries  [Not a public function] Convert hdataobj data to a tseries database.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

[solId,name,ixLog,nameLabel,contEList,contYList] = hdatareq(Obj);

switch This.Contrib
    case 'E'
        contList = contEList;
    case 'Y'
        contList = contYList;
    otherwise
        contList = {};
end

Range = Range(1) : Range(end);

template = tseries();

D = struct();

for i = 1 : length(solId)

    if isempty(solId{i})
        continue
    end
    
    iRealId = real(solId{i});
    iImagId = imag(solId{i});
    maxLag = -min(iImagId);

    xRange = Range(1)-maxLag : Range(end);
    xStart = xRange(1);
    nXPer = length(xRange);
    
    for j = find(iImagId == 0)
        
        pos = iRealId(j);
        jName = name{pos};
        if ~isfield(This.data,jName)
            continue
        end
        sn = size(This.data.(jName));
        if sn(1) ~= nXPer
            doThrowInternal();
        end
        if ixLog(pos)
            This.data.(jName) = exp(This.data.(jName));
        end
        
        % Create a new database entry.
        D.(jName) = template;
        D.(jName).start = xStart;
        D.(jName).data = This.data.(jName);
        D.(jName) = mytrim(D.(jName));
        if isempty(This.Contrib)
            D.(jName) = comment(D.(jName),nameLabel{pos});
        else
            D.(jName) = comment(D.(jName), ...
                utils.concomment(jName,contList,ixLog(pos)));
        end
        
        % Free memory.
        This.data.(jName) = [];
    end
    
end

if This.IsParam
    D = addparam(Obj,D);
end


% Nested functions...


%**************************************************************************
    function doThrowInternal()
        utils.error('hdataobj:hdata2tseries', ...
            ['Internal IRIS error. ', ...
            'Please report this error with a copy of the screen message.']);
    end % doThrowInternal()


end