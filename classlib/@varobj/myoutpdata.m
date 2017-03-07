function Outp = myoutpdata(This,Fmt,Rng,InpMean,InpMse,Names,AddDb) %#ok<INUSL>
% myoutpdata  [Not a public function] Output data for varobj objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    InpMse;
catch %#ok<CTCH>
    InpMse = [];
end

try
    Names;
    ix = strcmp(Names,'!ttrend');
    if any(ix)
        Names(ix) = {'ttrend'};
    end
catch %#ok<CTCH>
    Names = {};
end

try
    AddDb;
catch
    AddDb = struct();
end

%--------------------------------------------------------------------------

nx = size(InpMean,1);
if ~isempty(Rng)
    Rng = Rng(1) : Rng(end);
    nPer = numel(Rng);    
    start = Rng(1);
else
    Rng = zeros(1,0); %#ok<NASGU>
    nPer = 0;
    start = NaN;
end
nData3 = size(InpMean,3);
nData4 = size(InpMean,4);

% Prepare array of std devs if cov matrix is supplied.
if numel(InpMse) == 1 && isnan(InpMse)
    nStd = size(InpMean,1);
    std = nan(nStd,nPer,nData3,nData4);
elseif ~isempty(InpMse)
    InpMse = timedom.fixcov(InpMse);
    nStd = min(size(InpMean,1),size(InpMse,1));
    std = zeros(nStd,nPer,nData3,nData4);
    for i = 1 : nData3
        for j = 1 : nData4
            for k = 1 : nStd
                std(k,:,i,j) = permute(sqrt(InpMse(k,k,:,i,j)),[1,3,2,4,5]);
            end
        end
    end
end

if strcmpi(Fmt,'auto')
    if isempty(Names)
        Fmt = 'tseries';
    else
        Fmt = 'dbase';
    end
end

switch Fmt
    case 'tseries'
        template = tseries();
        doTseries();
    case 'dbase'
        template = tseries();
        doStruct();
    case 'array'
        doArray();
end

if ~strcmp(Fmt,'dbase')
    % ##### Feb 2014 OBSOLETE and scheduled for removal.
    utils.warning('obsolete', ...
        ['Using tseries objects as input/output data to/from VAR objects', ...
        'is obsolete, and will be removed from a future version of IRIS. ', ...
        'Use databases (structs) instead.']);
end


% Nested functions...


%**************************************************************************
   
    
    function doTseries()
        if isempty(InpMse)
            Outp = replace(template,permute(InpMean,[2,1,3,4]),start);
        else
            Outp = struct();
            Outp.mean = replace(template,permute(InpMean,[2,1,3,4]),start);
            Outp.std = replace(template,permute(std,[2,1,3,4]),start);
        end
    end % doTseries()


%**************************************************************************
   
    
    function doStruct()
        Outp = AddDb;
        for ii = 1 : nx
            Outp.(Names{ii}) = replace(template, ...
                permute(InpMean(ii,:,:,:),[2,3,4,1]), ...
                start, ...
                Names{ii});
        end
        if ~isempty(InpMse)
            Outp = struct('mean',Outp,'std',struct());
            for ii = 1 : nStd
                Outp.std.(Names{ii}) = replace(template, ...
                    permute(std(ii,:,:,:),[2,3,4,1]), ...
                    start, ...
                    Names{ii});
                Outp.std.(Names{ii}) = mytrim(Outp.std.(Names{ii}));
            end
        end
    end % doStruct()


%**************************************************************************
 
    
    function doArray()
        if isempty(InpMse)
            Outp = permute(InpMean,[2,1,3,4]);
        else
            Outp = struct();
            Outp.mean = permute(InpMean,[2,1,3,4]);
            Outp.std = permute(std,[2,1,3,4]);
        end
    end % doArray()


end
