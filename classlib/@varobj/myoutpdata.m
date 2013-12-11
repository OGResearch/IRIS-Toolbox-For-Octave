function Data = myoutpdata(This,Fmt,Rng,X,P,Names) %#ok<INUSL>
% myoutpdata  [Not a public function] Output data for varobj objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    P;
catch %#ok<CTCH>
    P = [];
end

try
    Names;
catch %#ok<CTCH>
    Names = {};
end

%--------------------------------------------------------------------------

nx = size(X,1);
Rng = Rng(1) : Rng(end);
nper = numel(Rng);
ndata3 = size(X,3);
ndata4 = size(X,4);

% Prepare array of std devs if cov matrix is supplied.
if numel(P) == 1 && isnan(P)
    nstd = size(X,1);
    std = nan(nstd,nper,ndata3,ndata4);
elseif ~isempty(P)
    P = timedom.fixcov(P);
    nstd = min([size(X,1),size(P,1)]);
    std = zeros(nstd,nper,ndata3,ndata4);
    for i = 1 : ndata3
        for j = 1 : ndata4
            for k = 1 : nstd
                std(k,:,i,j) = permute(sqrt(P(k,k,:,i,j)),[1,3,2,4,5]);
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
        dotseries();
    case 'dbase'
        template = tseries();
        dostruct();
    case 'array'
        doarray();
end

% Nested functions.

%**************************************************************************
    function dotseries()
        if isempty(P)
            Data = replace(template,permute(X,[2,1,3,4]),Rng(1));
        else
            Data = struct();
            Data.mean = replace(template,permute(X,[2,1,3,4]),Rng(1));
            Data.std = replace(template,permute(std,[2,1,3,4]),Rng(1));
        end
    end
% dotseries().

%**************************************************************************
    function dostruct()
        Data = struct();
        for ii = 1 : nx
            Data.(Names{ii}) = ...
                replace(template,permute(X(ii,:,:,:),[2,3,4,1]),Rng(1));
        end
        if ~isempty(P)
            Data = struct('mean',Data,'std',struct());
            for ii = 1 : nstd
                Data.std.(Names{ii}) = ...
                    replace(template,permute(std(ii,:,:,:),[2,3,4,1]),Rng(1));
                Data.std.(Names{ii}) = mytrim(Data.std.(Names{ii}));
            end
        end
    end
% dostruct().

%**************************************************************************
    function doarray()
        if isempty(P)
            Data = permute(X,[2,1,3,4]);
        else
            Data = struct();
            Data.mean = permute(X,[2,1,3,4]);
            Data.std = permute(std,[2,1,3,4]);
        end
    end
% doarray().

end
