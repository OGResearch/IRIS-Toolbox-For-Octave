function varargout = datarequest(Req,This,Data,Range,IData,LoglikOpt)
% datarequest  [Not a public function] Request data from database.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%#ok<*CTCH>
%#ok<*VUNUS>

try
    IData;
catch 
    IData = ':';
end

try
    LoglikOpt;
catch    
    LoglikOpt = [];
end

%--------------------------------------------------------------------------

nxx = size(This.solution{1},1);
nb = size(This.solution{1},2);
nf = nxx - nb;
nAlt = size(This.Assign,3);
Range = Range(1) : Range(end);
nPer = length(Range);

if isempty(Data)
    Data = struct();
end

dMean = [];
dMse = [];

if isstruct(Data) && isfield(Data,'mean')
    % Struct with `.mean` and possibly also `.mse`.
    if isfield(Data,'mean') && isstruct(Data.mean)
        dMean = Data.mean;
        if isfield(Data,'mse') && isa(Data.mse,'tseries')
            dMse = Data.mse;
        end
    end
elseif isstruct(Data)
    % Plain database.
    dMean = Data;
else
    utils.error('model','Unknown type of input data.');
end

% Warning structure for `db2array`.
warn = struct();
warn.NotFound = false;
warn.SizeMismatch = true;
warn.FreqMismatch = true;
warn.NonTseries = true;
warn.NoRangeFound = true;
% Starred requests throw a warning if one or more series is not found in
% the input database.
try %#ok<TRYNC>
    if isequal(Req(end),'*')
        warn.NotFound = true;
        Req(end) = '';
    end
end

switch lower(Req)
    case 'init'
        % Initial condition for the mean and MSE of Alpha.
        if nargout < 4
            [xbInitMean,ixNanInitMean] = doData2XbInit();
            xbInitMse = [];
            alpInitMean = doXbInit2AlpInit();
            varargout{1} = alpInitMean;
            varargout{2} = xbInitMean;
            varargout{3} = ixNanInitMean;
        else
            [xbInitMean,ixNanInitMean,xbInitMse,ixNanInitMse] = doData2XbInit();
            [alpInitMean,alpInitMse] = doXbInit2AlpInit();
            varargout{1} = alpInitMean;
            varargout{2} = xbInitMean;
            varargout{3} = ixNanInitMean;
            varargout{4} = alpInitMse;
            varargout{5} = xbInitMse;
            varargout{6} = ixNanInitMse;
        end
    case 'xbinit'
        % Initial condition for the mean and MSE of X.
        [varargout{1:nargout}] = doData2XbInit();
    case 'y'
        % Measurement variables; a star
        y = doData2Y();
        y = y(:,:,IData);
        varargout{1} = y;
    case 'yg'
        % Measurement variables, and exogenous variables for deterministic trends.
        y = doData2Y();
        y = y(:,:,IData);
        if ~isempty(LoglikOpt) && isstruct(LoglikOpt) ...
                && isfield(LoglikOpt,'domain') ...
                && strncmpi(LoglikOpt.domain,'f',1)
            y = permute(y,[2,1,3]);
            y = fft(y);
            y = ipermute(y,[2,1,3]);
        end
        g = doData2G();
        nYData = size(y,3);
        if size(g,3) == 1 && size(g,3) < nYData
            g = g(:,:,ones(1,nYData));
        end
        varargout{1} = [y;g];
    case 'e'
        varargout{1} = doData2E();
    case 'x'
        varargout{1} = doData2X();
    case 'y,x,e'
        Data = {doData2Y(),doData2X(),doData2E()};
        nData = max([size(Data{1},3),size(Data{2},3),size(Data{3},3)]);
        % Make the size of all data arrays equal in 3rd dimension.
        if size(Data{1},3) < nData
            Data{1} = cat(3,Data{1}, ...
                Data{1}(:,:,end*ones(1,nData-size(Data{1},3))));
        end
        if size(Data{2},3) < nData
            Data{2} = cat(3,Data{2}, ...
                Data{2}(:,:,end*ones(1,nData-size(Data{2},3))));
        end
        if size(Data{3},3) < nData
            Data{3} = cat(3,Data{3}, ...
                Data{3}(:,:,end*ones(1,nData-size(Data{3},3))));
        end
        varargout = Data;
    case 'g'
        % Exogenous variables for deterministic trends.
        varargout{1} = doData2G();
    case 'alpha'
        varargout{1} = doData2Alpha();
end


% Nested functions...


%**************************************************************************

    
    function [XbInitMean,IxNanInitMean,XbInitMse,IxNanInitMse] ...
            = doData2XbInit()
        XbInitMean = nan(nb,1,nAlt);
        XbInitMse = [];
        % Xf Mean.
        if ~isempty(dMean)
            realId = real(This.solutionid{2}(nf+1:end));
            imagId = imag(This.solutionid{2}(nf+1:end));
            sw = struct();
            sw.LagOrLead = imagId;
            sw.LogSign = This.LogSign(realId);
            sw.Warn = warn;
            XbInitMean = db2array(dMean,This.name(realId),Range(1)-1,sw);
            XbInitMean = permute(XbInitMean,[2,1,3]);
        end
        % Xf MSE.
        if nargout >= 3 && ~isempty(dMse)
            XbInitMse = rangedata(dMse,Range(1)-1);
            XbInitMse = ipermute(XbInitMse,[3,2,1,4]);
        end
        % Detect NaN init conditions.
        IxNanInitMean = false(nb,1);
        IxNanInitMse = false(nb,1);
        for ii = 1 : size(XbInitMean,3)
            required = This.icondix(1,:,min(ii,end));
            required = required(:);
            IxNanInitMean = IxNanInitMean | ...
                (isnan(XbInitMean(:,1,ii)) & required);
            if ~isempty(XbInitMse)
                IxNanInitMse = IxNanInitMse | ...
                    (any(isnan(XbInitMse(:,:,ii)),2) & required);
            end
        end
        % Report NaN init conditions in mean.
        if any(IxNanInitMean)
            id = This.solutionid{2}(nf+1:end);
            IxNanInitMean = myvector(This,id(IxNanInitMean)-1i);
        else
            IxNanInitMean = {};
        end
        % Report NaN init conditions in MSE.
        if any(IxNanInitMse)
            id = This.solutionid{2}(nf+1:end);
            IxNanInitMse = myvector(This,id(IxNanInitMse)-1i);
        else
            IxNanInitMse = {};
        end
    end % doData2XInit()


%**************************************************************************


% Get initial conditions for xb and alpha.
% Those that are not required are set to `NaN` in `xInitMean, and
% to 0 when computing `aInitMean`.
    function [AlpInitMean,AlpInitMse] = doXbInit2AlpInit()
        % Transform Mean[Xb] to Mean[Alpha].
        nData = size(xbInitMean,3);
        if nData < nAlt
            xbInitMean(:,1,end+1:nAlt) = ...
                xbInitMean(:,1,end*ones(1,nAlt-nData));
            nData = nAlt;
        end
        AlpInitMean = xbInitMean;
        for iiData = 1 : nData
            U = This.solution{7}(:,:,min(iiData,end));
            if all(~isnan(U(:)))
                notRequired = ~This.icondix(1,:,min(iiData,end));
                inx = isnan(xbInitMean(:,1,iiData)) & notRequired(:);
                AlpInitMean(inx,1,iiData) = 0;
                AlpInitMean(:,1,iiData) = U\AlpInitMean(:,1,iiData);
            else
                AlpInitMean(:,1,iiData) = NaN;
            end
        end
        % Transform MSE[Xb] to MSE[Alpha].
        if nargout < 2 || isempty(xbInitMse)
            AlpInitMse = xbInitMse;
            return
        end
        nData = size(xbInitMse,4);
        if nData < nAlt
            xbInitMse(:,:,1,end+1:nAlt) = ...
                xbInitMse(:,:,1,end*ones(1,nAlt-nData));
            nData = nAlt;
        end
        AlpInitMse = xbInitMse;
        for iiData = 1 : nData
            U = This.solution{7}(:,:,min(iiData,end));
            if all(~isnan(U(:)))
                AlpInitMse(:,:,1,iiData) = U\AlpInitMse(:,:,1,iiData);
                AlpInitMse(:,:,1,iiData) = AlpInitMse(:,:,1,iiData)/U.';
            else
                AlpInitMse(:,:,1,iiData) = NaN;
            end
        end
    end % doXInit2AInit()


%**************************************************************************

    
    function Y = doData2Y()
        if ~isempty(dMean)
            inx = This.nametype == 1;
            sw = struct();
            sw.LagOrLead = [];
            sw.LogSign = This.LogSign(inx);
            sw.Warn = warn;
            Y = db2array(dMean,This.name(inx),Range,sw);
            Y = permute(Y,[2,1,3]);
        end
    end % doData2Y()


%**************************************************************************

    
    function E = doData2E()
        if ~isempty(dMean)
            inx = This.nametype == 3;
            sw = struct();
            sw.LagOrLead = [];
            sw.LogSign = [];
            sw.Warn = warn;
            E = db2array(dMean,This.name(inx),Range,sw);
            E = permute(E,[2,1,3]);
        end
        eReal = real(E);
        eImag = imag(E);
        eReal(isnan(eReal)) = 0;
        eImag(isnan(eImag)) = 0;
        E = eReal + 1i*eImag;
    end % dodata2e()


%**************************************************************************
    
    
    function G = doData2G()
        ng = sum(This.nametype == 5);
        if ng > 0 && ~isempty(dMean)
            name = This.name(This.nametype == 5);
            sw = struct();
            sw.LagOrLead = [];
            sw.LogSign = [];
            sw.Warn = warn;
            G = db2array(dMean,name,Range,sw);
            G = permute(G,[2,1,3]);
        else
            G = nan(ng,nPer);
        end
    end % doData2G()


%**************************************************************************


% Get current dates of transition variables.
% Set lags and leads to NaN.
    function X = doData2X()
        realId = real(This.solutionid{2});
        imagId = imag(This.solutionid{2});
        currentInx = imagId == 0;
        if ~isempty(dMean)
            realId = realId(currentInx);
            imagId = imagId(currentInx);
            sw = struct();
            sw.LagOrLead = imagId;
            sw.LogSign = This.LogSign(realId);
            sw.Warn = warn;
            x = db2array(dMean,This.name(realId),Range,sw);
            x = permute(x,[2,1,3]);
            %X = nan(length(inx),size(x,2),size(x,3));
            X = nan(nxx,size(x,2),size(x,3));
            X(currentInx,:,:) = x;
        end
    end % doData2X()


%**************************************************************************

    
    function A = doData2Alpha()
        if ~isempty(dMean)
            realId = real(This.solutionid{2});
            imagId = imag(This.solutionid{2});
            realId = realId(nf+1:end);
            imagId = imagId(nf+1:end);
            sw = struct();
            sw.LagOrLead = imagId;
            sw.LogSign = This.LogSign(realId);
            sw.Warn = warn;
            A = db2array(dMean,This.name(realId),Range,sw);
            A = permute(A,[2,1,3]);
        end
        nData = size(A,3);
        if nData < nAlt
            A(:,:,end+1:nAlt) = A(:,:,end*ones(1,nAlt-nData));
            nData = nAlt;
        end
        for ii = 1 : nData
            U = This.solution{7}(:,:,min(ii,end));
            if all(~isnan(U(:)))
                A(:,:,ii) = U\A(:,:,ii);
            else
                A(:,:,ii) = NaN;
            end
        end
    end % doData2Alpha()


end