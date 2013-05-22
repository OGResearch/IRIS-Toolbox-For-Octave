function varargout = datarequest(Req,This,Data,Range,IData,LoglikOpt)
% datarequest  [Not a public function] Request data from database.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

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

switch Req
    case 'init'
        % Initial condition for the mean and MSE of Alpha.
        if nargout < 4
            [xInitMean,nanInitMean] = doData2XInit();
            xInitMse = [];
            aInitMean = doXInit2AInit();
            varargout{1} = aInitMean;
            varargout{2} = xInitMean;
            varargout{3} = nanInitMean;
        else
            [xInitMean,nanInitMean,xInitMse,nanInitMse] = doData2XInit();
            [aInitMean,aInitMse] = doXInit2AInit();
            varargout{1} = aInitMean;
            varargout{2} = xInitMean;
            varargout{3} = nanInitMean;
            varargout{4} = aInitMse;
            varargout{5} = xInitMse;
            varargout{6} = nanInitMse;
        end
    case 'xinit'
        % Initial condition for the mean and MSE of X.
        [varargout{1:nargout}] = doData2XInit();
    case 'y'
        y = doData2Y();
        y = y(:,:,IData);
        varargout{1} = y;
    case 'yg'
        y = doData2Y();
        y = y(:,:,IData);
        if ~isempty(LoglikOpt) && isstruct(LoglikOpt) ...
                && isfield(LoglikOpt,'domain') ...
                && strncmpi(LoglikOpt.domain,'f',1)
            y = fft(y.').';
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
        varargout{1} = doData2G();
    case 'alpha'
        varargout{1} = doData2Alpha();
end

% Nested functions.

%**************************************************************************
    function [XInitMean,NanInitMean,XInitMse,NanInitMse] = doData2XInit()
        XInitMean = nan(nb,1,nAlt);
        XInitMse = [];
        % Mean.
        if ~isempty(dMean)
            realId = real(This.solutionid{2}(nf+1:end));
            imagId = imag(This.solutionid{2}(nf+1:end));
            XInitMean = db2array(dMean,This.name(realId),Range(1)-1, ...
                imagId,This.log(realId),false,true,true,true);
            XInitMean = permute(XInitMean,[2,1,3]);
        end
        % MSE.
        if nargout >= 3 && ~isempty(dMse)
            XInitMse = rangedata(dMse,Range(1)-1);
            XInitMse = ipermute(XInitMse,[3,2,1,4]);
        end
        % Detect NaN init conditions.
        NanInitMean = false(nb,1);
        NanInitMse = false(nb,1);
        for ii = 1 : size(XInitMean,3)
            required = This.icondix(1,:,min(ii,end));
            required = required(:);
            NanInitMean = NanInitMean | ...
                (isnan(XInitMean(:,1,ii)) & required);
            if ~isempty(XInitMse)
                NanInitMse = NanInitMse | ...
                    (any(isnan(XInitMse(:,:,ii)),2) & required);
            end
        end
        % Report NaN init conditions in mean.
        if any(NanInitMean)
            id = This.solutionid{2}(nf+1:end);
            NanInitMean = myvector(This,id(NanInitMean)-1i);
        else
            NanInitMean = {};
        end
        % Report NaN init conditions in MSE.
        if any(NanInitMse)
            id = This.solutionid{2}(nf+1:end);
            NanInitMse = myvector(This,id(NanInitMse)-1i);
        else
            NanInitMse = {};
        end
    end % doData2XInit().

%**************************************************************************
% Get initial conditions for xb and alpha.
% Those that are not required are set to `NaN` in `xInitMean, and
% to 0 when computing `aInitMean`.
    function [AInitMean,AInitMse] = doXInit2AInit()
        % Transform mean x to alpha.
        nData = size(xInitMean,3);
        if nData < nAlt
            xInitMean(:,1,end+1:nAlt) = ...
                xInitMean(:,1,end*ones(1,nAlt-nData));
            nData = nAlt;
        end
        AInitMean = xInitMean;
        for ii = 1 : nData
            U = This.solution{7}(:,:,min(ii,end));
            notrequired = ~This.icondix(1,:,min(ii,end));
            index = isnan(xInitMean(:,1,ii)) & notrequired(:);
            AInitMean(index,1,ii) = 0;
            AInitMean(:,1,ii) = U\AInitMean(:,1,ii);
        end
        % Transform MSE x to alpha.
        if nargout < 2 || isempty(xInitMse)
            AInitMse = xInitMse;
            return
        end
        nData = size(xInitMse,4);
        if nData < nAlt
            xInitMse(:,:,1,end+1:nAlt) = ...
                xInitMse(:,:,1,end*ones(1,nAlt-nData));
            nData = nAlt;
        end
        AInitMse = xInitMse;
        for ii = 1 : nData
            U = This.solution{7}(:,:,min(ii,end));
            Ut = U.';
            AInitMse(:,:,1,ii) = U\AInitMse(:,:,1,ii);
            AInitMse(:,:,1,ii) = AInitMse(:,:,1,ii)/Ut;
        end
    end % doXInit2AInit().

%**************************************************************************
    function Y = doData2Y()
        if ~isempty(dMean)
            realId = real(This.solutionid{1});
            imagId = imag(This.solutionid{1});
            tmpLog = This.log(realId);
            Y = db2array(dMean,This.name(realId),Range, ...
                imagId,tmpLog,false,true,true,true);
            Y = permute(Y,[2,1,3]);
        end
    end % doData2Y().

%**************************************************************************
    function E = doData2E()
        if ~isempty(dMean)
            realid = real(This.solutionid{3});
            imagid = imag(This.solutionid{3});
            E = db2array(dMean,This.name(realid),Range, ...
                imagid,This.log(realid),false,true,true,true);
            E = permute(E,[2,1,3]);
        end
        eReal = real(E);
        eImag = imag(E);
        eReal(isnan(eReal)) = 0;
        eImag(isnan(eImag)) = 0;
        E = eReal + 1i*eImag;
    end % dodata2e().

%**************************************************************************
    function G = doData2G()
        ng = sum(This.nametype == 5);
        if ng > 0 && ~isempty(dMean)
            name = This.name(This.nametype == 5);
            G = db2array(dMean,name,Range, ...
                zeros(size(name)),false(size(name)), ...
                false,true,true,true);
            G = permute(G,[2,1,3]);
        else
            G = nan(ng,nPer);
        end
    end % doData2G().

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
            tmpLog = This.log(realId);
            x = db2array(dMean,This.name(realId),Range, ...
                imagId,tmpLog,false,true,true,true);
            x = permute(x,[2,1,3]);
            %X = nan(length(inx),size(x,2),size(x,3));
            X = nan(nxx,size(x,2),size(x,3));
            X(currentInx,:,:) = x;
        end
    end % doData2X().

%**************************************************************************
    function A = doData2Alpha()
        if ~isempty(dMean)
            realId = real(This.solutionid{2});
            imagId = imag(This.solutionid{2});
            realId = realId(nf+1:end);
            imagId = imagId(nf+1:end);
            A = db2array(dMean,This.name(realId),Range, ...
                imagId,This.log(realId),false,true,true,true);
            A = permute(A,[2,1,3]);
        end
        nData = size(A,3);
        if nData < nAlt
            A(:,:,end+1:nAlt) = A(:,:,end*ones(1,nAlt-nData));
            nData = nAlt;
        end
        for ii = 1 : nData
            U = This.solution{7}(:,:,min(ii,end));
            A(:,:,ii) = U\A(:,:,ii);
        end
    end % doData2Alpha().

end