function D = hdata2tseries(This,Obj,Range)
% hdata2tseries  [Not a public function] Convert hdataobj data to a tseries database.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

[solId,name,Log,nameLabel,contEList,contYList] = hdatareq(Obj);

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
        if Log(pos)
            This.data.(jName) = exp(This.data.(jName));
        end
        
        % Create a new database entry.
        D.(jName) = template;
        D.(jName).start = xStart;
        D.(jName).data = This.data.(jName);
        doComments();
        D.(jName) = mytrim(D.(jName));
        
        % Free memory.
        This.data.(jName) = [];
    end
    
end

if This.IsParam
    D = addparam(Obj,D);
end

% Nested functions.

%**************************************************************************
    function doThrowInternal()
        error('IRIS:hdataobj', ...
            ['Internal IRIS error. ', ...
            'Please report this error with a copy of the screen message.']);
    end % doThrowInternal().

%**************************************************************************
    function doComments()
        if isempty(This.Contrib)
            c = cell([1,sn(2:end)]);
            if ~isempty(nameLabel{pos})
                c(:) = nameLabel(pos);
            else
                c(:) = name(pos);
            end
        else
            switch This.Contrib
                case 'E'
                    c = [contEList,{'Init + Const'}];
                case 'Y'
                    c = contYList;
            end
            if Log(pos)
                sign = '*';
            else
                sign = '+';
            end
            replace = [name{pos},' <--[',sign','] $0'];
            c = regexprep(c,'.*',replace,'once');
        end
        D.(jName).Comment = c;
    end % doComments().

end