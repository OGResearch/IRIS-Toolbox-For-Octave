function [OutpFmt,Range,Y,E,I] = mydatarequest(This,Data,Range,Opt)
% mydatarequest  [Not a public function] Request input data.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

ise = nargout > 3;
isi = nargout > 4;

try
    Opt; %#ok<VUNUS>
catch %#ok<CTCH>
    Opt = struct();
end

%--------------------------------------------------------------------------

ny = length(This.YNames);

if isi
    ni = length(This.INames);
end

if any(isinf(Range))
    Range = Inf;
    infRange = true;
else
    if ~isempty(Range)
        Range = Range(1) : Range(end);
    end
    infRange = false;
end

if isstruct(Data)
    [Y,E,I] = doStruct();
    inpFmt = 'dbase';
elseif is.tseries(Data)
    [Y,E] = doTseries();
    I = [];
    inpFmt = 'tseries';
    
    % ##### Feb 2014 OBSOLETE and scheduled for removal.
    utils.warning('obsolete', ...
        ['Using tseries objects as input/output data to/from VAR objects', ...
        'is obsolete, and will be removed from a future version of IRIS. ', ...
        'Use databases (structs) instead.']);
    
elseif ~isempty(Data)
    [Y,E] = doArray();
    I = [];
    inpFmt = 'array';
else
    [Y,E] = doElse();
    I = [];
    inpFmt = 'dbase';
end

% Transpose data.
Y = permute(Y,[2,1,3]);
if ise
    E = permute(E,[2,1,3]);
end
if isi
    nPer = length(Range);
    if isempty(I)
        I = nan(nPer,ni,size(Y,3));
    end
    I = permute(I,[2,1,3]);
end

% Determine output format.
if ~isfield(Opt,'output') || strcmpi(Opt.output,'auto')
    OutpFmt = inpFmt;
else
    OutpFmt = Opt.output;
end


% Nested functions.


%**************************************************************************
    function [y,e,fi] = doStruct()
        yNames = This.YNames;
        if infRange
            Range = dbrange(Data,yNames);
        end
        nPer = length(Range);
        y = [];
        for i = 1 : ny
            name = This.YNames{i};
            if isfield(Data,name) && is.tseries(Data.(name))
                yi = rangedata(Data.(name),Range);
                yi = permute(yi,[1,3,2]);
            else
                yi = nan(nPer,1,size(y,3));
            end
            y = [y,yi]; %#ok<AGROW>
        end
        % Residuals.
        e = [];
        if ise
            for i = 1 : ny
                name = This.ENames{i};
                if isfield(Data,name) ...
                        && isa(Data.(name),'tseries')
                    ei = rangedata(Data.(name),Range);
                    ei = permute(ei,[1,3,2]);
                else
                    ei = zeros(nPer,1,size(e,3));
                end
                e = [e,ei]; %#ok<AGROW>
            end
        end
        % Forecast instruments.
        fi = [];
        if isi
            iNames = This.INames;
            ni = length(This.INames);
            for i = 1 : ni
                name = iNames{i};
                if isfield(Data,name) ...
                        && isa(Data.(name),'tseries')
                    fii = rangedata(Data.(name),Range);
                    fii = permute(fii,[1,3,2]);
                else
                    fii = nan(nPer,1,size(fi,3));
                end
                fi = [fi,fii]; %#ok<AGROW>
            end
        end
    end % doStruct().


%**************************************************************************
    function [Y,E] = doTseries()
        [Y,Range] = rangedata(Data,Range);
        if size(Y,2) == 2*ny
            E = Y(:,ny+1:end,:);
            Y = Y(:,1:ny,:);
        else
            E = zeros(size(Y));
        end
    end % doTseries().


%**************************************************************************
    function [Y,E] = doArray()
        if infRange
            Range = 1 : size(Data,1);
        end
        nPer = length(Range);
        index = Range >= 1 & Range <= size(Data,1);
        Y = nan([nPer,size(Data,2),size(Data,3)]);
        Y(index,:,:) = Data(Range(index),:,:);
        if size(Y,2) == 2*ny
            E = Y(:,ny+1:end,:);
            Y = Y(:,1:ny,:);
        else
            E = zeros(size(Y));
        end
    end % doArray().


%**************************************************************************
    function [Y,E] = doElse()
        if infRange
            nPer = 0;
        else
            nPer = length(Range);
        end
        Y = nan(nPer,ny);
        E = nan(nPer,ny);
        % inputFormat = 'array';
    end % doElse().


end