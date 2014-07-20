function D = hdata2tseries(This)
% hdata2tseries  [Not a public function] Convert hdataobj data to a tseries database.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

template = tseries();
realexp = @(x) real(exp(x));

D = struct();

for i = 1 : length(This.Id)

    if isempty(This.Id{i})
        continue
    end
    
    realId = real(This.Id{i});
    imagId = imag(This.Id{i});
    maxLag = -min(imagId);

    xRange = This.Range(1)-maxLag : This.Range(end);
    xStart = xRange(1);
    nXPer = length(xRange);
    
    for j = find(imagId == 0)
        
        pos = realId(j);
        jName = This.Name{pos};
        if ~isfield(This.Data,jName)
            continue
        end
        sn = size(This.Data.(jName));
        if sn(1) ~= nXPer
            doThrowInternal();
        end
        if This.IxLog(pos)
            This.Data.(jName) = realexp(This.Data.(jName));
        end
        
        % Create a new database entry.
        D.(jName) = template;
        D.(jName) = mystamp(D.(jName));
        D.(jName).start = xStart;
        D.(jName).data = This.Data.(jName);
        s = size(D.(jName).data);
        D.(jName) = comment(D.(jName),repmat({''},[1,s(2:end)]));
        D.(jName) = mytrim(D.(jName));
        if isempty(This.Contributions)
            c = This.Label{pos};
        else
            c = utils.concomment(jName, ...
                This.Contributions,This.IxLog(pos));
        end
        D.(jName) = comment(D.(jName),c);
        
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
