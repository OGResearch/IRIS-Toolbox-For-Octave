function D = hdata2tseries(This)
% hdata2tseries  [Not a public function] Convert hdataobj data to a tseries database.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

template = tseries();

D = struct();

for i = 1 : length(This.Id)

    if isempty(This.Id{i})
        continue
    end
    
    iRealId = real(This.Id{i});
    iImagId = imag(This.Id{i});
    maxLag = -min(iImagId);

    xRange = This.Range(1)-maxLag : This.Range(end);
    xStart = xRange(1);
    nXPer = length(xRange);
    
    for j = find(iImagId == 0)
        
        pos = iRealId(j);
        jName = This.Name{pos};
        if ~isfield(This.Data,jName)
            continue
        end
        sn = size(This.Data.(jName));
        if sn(1) ~= nXPer
            doThrowInternal();
        end
        if This.Log(pos)
            This.Data.(jName) = exp(This.Data.(jName));
        end
        
        % Create a new database entry.
        D.(jName) = template;
        D.(jName).start = xStart;
        D.(jName).data = This.Data.(jName);
        s = size(D.(jName).data);
        D.(jName).Comment = repmat({''},[1,s(2:end)]);
        D.(jName) = mytrim(D.(jName));
        if isempty(This.Contrib)
            D.(jName) = comment(D.(jName),This.Label{pos});
        else
            D.(jName) = comment(D.(jName), ...
                utils.concomment(jName,This.Contrib,This.Log(pos)));
        end
        
        % Free memory.
        This.Data.(jName) = [];
    end
    
end

if This.IncludeParam
    list = fieldnames(This.ParamDb);
    for i = 1 : length(list)
    	D.(list{i}) = This.ParamDb.(list{i});
    end
end


% Nested functions...


%**************************************************************************


    function doThrowInternal()
        utils.error('hdataobj:hdata2tseries','#Internal');
    end % doThrowInternal()


end