function Outp = datarequest(Req,This,Data,Range,Opt)
% datarequest  [Not a public function] Request input data.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Req: 'y', 'e'
% Outp.Range
% Outp.Y
% Outp.E
% Outp.Format

try
    Opt; %#ok<VUNUS>
catch %#ok<CTCH>
    Opt = struct();
end

%--------------------------------------------------------------------------

retY = ~isempty(strfind(Req,'y'));
mustY = ~isempty(strfind(Req,'y*'));
retE = ~isempty(strfind(Req,'e'));
mustE = ~isempty(strfind(Req,'e*'));

Y = [];
E = [];

ny = length(This.YNames);

if any(isinf(Range))
    Range = Inf;
    isInfRange = true;
else
    if ~isempty(Range)
        Range = Range(1) : Range(end);
    end
    isInfRange = false;
end

if isstruct(Data)
    doDbase();
    inpFmt = 'dbase';
elseif is.tseries(Data)
    doTseries();
    inpFmt = 'tseries';
    
    % ##### Feb 2014 OBSOLETE and scheduled for removal.
    utils.warning('obsolete', ...
        ['Using tseries objects as input/output data to/from VAR objects', ...
        'is obsolete, and will be removed from a future version of IRIS. ', ...
        'Use databases (structs) instead.']);
    
elseif ~isempty(Data)
    doArray();
    inpFmt = 'array';
else
    doElse();
    inpFmt = 'dbase';
end

% Transpose and return data.
Outp.Range = Range;
if retY
    Outp.Y = permute(Y,[2,1,3]);
end
if retE
    Outp.E = permute(E,[2,1,3]);
end

% Determine output format.
if ~isfield(Opt,'output') || strcmpi(Opt.output,'auto')
    Outp.Format = inpFmt;
else
    Outp.Format = Opt.output;
end


% Nested functions...


%**************************************************************************

    
    function doDbase()
        
        yNames = This.YNames;
        if isInfRange
            Range = dbrange(Data,yNames);
        end
        
        sw = struct();
        sw.Warn.SizeMismatch = true;
        sw.Warn.FreqMismatch = true;
        sw.Warn.NoRangeFound = true;
        sw.LagOrLead = [];
        sw.Log = [];
        sw.BaseYear = This.BaseYear;
        
        if retY
            sw.Warn.NotFound = mustY;
            sw.Warn.NonTseries = mustY;
            Y = db2array(Data,Range,This.YNames,sw);
        end

        if retE
            sw.Warn.NotFound = mustE;
            sw.Warn.NonTseries = mustE;
            E = db2array(Data,Range,This.ENames,sw);
        end
        
    end % doDbase()


%**************************************************************************
    
    
    function doTseries()
        [Y,Range] = rangedata(Data,Range);
        if size(Y,2) == 2*ny
            E = Y(:,ny+1:end,:);
            Y = Y(:,1:ny,:);
        else
            E = zeros(size(Y));
        end
    end % doTseries()


%**************************************************************************
   
    
    function doArray()
        if isInfRange
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
    end % doArray()


%**************************************************************************
   
    
    function doElse()
        if isInfRange
            nPer = 0;
        else
            nPer = length(Range);
        end
        Y = nan(nPer,ny);
        E = nan(nPer,ny);
    end % doElse()


end