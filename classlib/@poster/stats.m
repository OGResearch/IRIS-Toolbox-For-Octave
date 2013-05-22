function Stat = stats(This,Theta,varargin)
% stats  Evaluate selected statistics of ARWM chain.
%
% Syntax
% =======
%
%     S = stats(Pos,Theta,...)
%     S = stats(Pos,Theta,LogPost,...)
%     S = stats(Pos,FName,...)
%
% Input arguments
% ================
%
% * `Pos` [ poster ] - Posterior simulator object that has generated the
% `Theta` chain.
%
% * `Theta` [ numeric ] - MCMC chain generated by the
% [`poster/arwm`](poster/arwm) function.
%
% * `LogPost` [ numeric ] - Vector of log posterior densities generated by
% the `arwm` function; `LogPost` is not necessary if you do not request
% `'mdd'`, the marginal data density.
%
% * `FName` [ char ] - File name under which the simulated chain was saved
% when `arwm` was run with options `saveEvery=`' and `'saveAs='`.
%
% Output arguments
% =================
%
% * `S` [ struct ] - Struct with the statistics requested by the user.
%
% Options
% ========
%
% * `'estTime='` [ `true` | *`false`* ] - Display and update the estimated time
% to go in the command window.
%
% * `'mddGrid='` [ numeric | *`0.1:0.1:0.9`* ] - Points between 0 and 1
% over which the marginal data density estimates will be averaged, see
% Geweke (1999).
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the
% command window.
%
% Options to include/exclude output statistics
% =============================================
%
% * `'bounds='` [ `true` | *`false`* ] - Include in `S` the lower and upper
% parameter bounds set up by the user.
%
% * `'chain='` [ *`true`* | `false` ] - Include in `S` the entire simulated
% chains of parameter values.
%
% * `'cov='` [ `true` | *`false`* ] - Include in `S` the sample covariance
% matrix.
%
% * '`hist=`' [ numeric | *empty* ] - Include in `S` histogram bins and counts
% with the specified number of bins.
%
% * `'hpdi='` [ *`false`* | numeric ] - Include in `S` the highest
% probability density intervals with the specified coverage.
%
% * `'ksdensity='` [ `true` | *`false`* | numeric ] - Include in `S` the x-
% and y-axis points for kernel-smoothed posterior density; use a numeric
% value to control the number of points over which the density is computed.
%
% * `'mdd='` [ *`true`* | `false` ] - Include in `S` minus the log marginal
% data density.
%
% * `'mean='` [ *`true`* | `false` ] - Include in `S` the sample averages.
%
% * `'median='` [ `true` | *`false`* ] - Include in `S` the sample medians.
%
% * `'mode='` [ `true` | *`false`* ] - Include in `S` the sample modes
% based on histograms.
%
% * `'prctile='` [ numeric | *empty* ] - Include in `S` the specified
% percentiles.
%
% * `'std='` [ *`true`* | `false` ] - Include in `S` the sample std
% deviations.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if ~isempty(varargin) && isnumeric(varargin{1})
    LogPost = varargin{1};
    varargin(1) = [];
else
    LogPost = [];
end

opt = passvalopt('poster.stats',varargin{:});

doOutpOpt();

% Simulated chain has been saved in a collection of mat files.
isFile = ischar(Theta);

if opt.mdd && isempty(LogPost) && ~isFile
    utils.error('poster', ...
        ['Vector of log posterior densities must be entered ', ...
        'if ``mdd`` is requested.']);
end

%--------------------------------------------------------------------------

Stat = struct();
nPar = length(This.paramList);

if isFile
    inpFile = Theta;
    nDraw = NaN;
    saveEvery = NaN;
    doChkPosterFile();
    getThetaFunc = @(I) h5read(inpFile,'/theta',[I,1],[1,Inf]);
    getLogPostFunc = @() h5read(inpFile,'/logPost',[1,1],[1,Inf]);
else
    [nPar,nDraw] = size(Theta);
end

if opt.mean || opt.cov || opt.std || opt.mdd
    thetaMean = nan(nPar,1);
    doMean();
end

if opt.progress
    progress = progressbar('IRIS poster.arwm progress');
elseif opt.esttime
    eta = esttime('IRIS poster.arwm is running');
end

for i = 1 : nPar
    name = This.paramList{i};
    
    if isFile
        iTheta = getThetaFunc(i);
    else
        iTheta = Theta(i,:);
    end
    
    if opt.mode || opt.hist
        [histCount,histBins] = hist(iTheta,opt.histbins);
    end
    
    if opt.chain
        Stat.chain.(name) = iTheta;
    end
    if opt.mean
        Stat.mean.(name) = thetaMean(i);
    end
    if opt.median
        Stat.median.(name) = median(iTheta);
    end
    if opt.mode
        pos = find(histCount == max(histCount));
        % If more than one mode is found, pick the middle one.
        npos = length(pos);
        if npos > 1
            pos = pos(ceil((npos+1)/2));
        end
        Stat.mode.(name) = histBins(pos);
    end
    if opt.std
        Stat.std.(name) = ...
            sqrt(sum((iTheta - thetaMean(i)).^2) / (nDraw-1));
    end
    if isnumeric(opt.hpdi) && ~isempty(opt.hpdi)
        [low,high] = tseries.myhpdi(iTheta,opt.hpdicover,2);
        Stat.hpdi.(name) = [low,high];
    end
    if isnumeric(opt.hist) && ~isempty(opt.hist)
        Stat.hist.(name) = {histBins,histCount};
    end
    if isnumeric(opt.prctile) && ~isempty(opt.prctile)
        Stat.prctile.(name) = prctile(iTheta,opt.prctile,2);
    end
    if opt.bounds
        Stat.bounds.(name) = [This.lowerBounds(i),This.upperBounds(i)];
    end
    if ~isequal(opt.ksdensity,false)
        low = This.lowerBounds(i);
        high = This.upperBounds(i);
        [x,y] = poster.myksdensity(iTheta,low,high,opt.ksdensity);
        Stat.ksdensity.(name) = [x,y];
    end
    
    if opt.progress
        update(progress,i/nPar);
    elseif opt.esttime
        update(eta,i/nPar);
    end
    
end

% Subtract the mean from `Theta`; the original `Theta` is not available
% any longer after this point.
if opt.cov || opt.mdd
    Sgm = nan(nPar);
    doCov();
end

if opt.cov
    Stat.cov = Sgm;
end

if opt.mdd
    uuu = nan(1,nDraw);
    doUuu();
    Stat.mdd = doMdd();
end

% Nested functions.

%**************************************************************************
    function doMean()
        if isFile
            for ii = 1 : nPar
                iTheta = getThetaFunc(ii);
                thetaMean(ii) = sum(iTheta) / nDraw;
            end
        else
            thetaMean = sum(Theta,2) / nDraw;
        end
    end % doMean().

%**************************************************************************
    function doCov()
        if isFile
            Sgm = zeros(nPar);
            for ii = 1 : saveEvery : nDraw
                chunk = min(saveEvery,1 + nDraw - ii);
                thetaChunk = h5read(inpFile,'/theta',[1,ii],[Inf,chunk]);
                for jj = 1 : nPar
                    thetaChunk(jj,:) = thetaChunk(jj,:) - thetaMean(jj);
                end
                Sgm = Sgm + thetaChunk * thetaChunk.' / nDraw;
            end
        else
            for ii = 1 : nPar
                Theta(ii,:) = Theta(ii,:) - thetaMean(ii);
            end
            Sgm = Theta * Theta.' / nDraw;
        end
    end % doCov().

%**************************************************************************
    function d = doMdd()
        % doMdd  Modified harmonic mean estimator of minus the log marginal data
        % density; Geweke (1999).
        
        % Copyright (c) 2010-2013 IRIS Solutions Team & Troy Matheson.
        logDetSgm = log(det(Sgm));
        
        % Compute g(theta) := f(theta) / post(theta) for all thetas,
        % where f(theta) is given by (4.3.2) in Geweke (1999).
        if isFile
            LogPost = getLogPostFunc();
        end
        logG = -(nPar*log(2*pi) + logDetSgm + uuu)/2 - LogPost;
        
        % Normalise the values of the g function by its average so that the
        % later sums does not grow too high. We're adding `avglogg` back
        % again.
        avgLogG = sum(logG) / nDraw;
        logG = logG - avgLogG;
        
        d = [];
        for pr = opt.mddgrid(:).'
            crit = chi2inv(pr,nPar);
            inx = crit >= uuu;
            if any(inx)
                tmp = sum(exp(-log(pr) + logG(inx))) / nDraw;
                d(end+1) = log(tmp) + avgLogG; %#ok<AGROW>
            end
        end
        d = -mean(d);
    end % doMdd().

%**************************************************************************
    function doUuu()
        invSgm = inv(Sgm);
        if isFile
            pos = 0;
            for ii = 1 : saveEvery : nDraw
                chunk = min(saveEvery,1 + nDraw - ii);
                thetaChunk = h5read(inpFile,'/theta',[1,ii],[Inf,chunk]);
                for jj = 1 : nPar
                    thetaChunk(jj,:) = thetaChunk(jj,:) - thetaMean(jj);
                end
                for jj = 1 : size(thetaChunk,2)
                    pos = pos + 1;
                    uuu(pos) = ...
                        thetaChunk(:,jj).' * invSgm * thetaChunk(:,jj); %#ok<MINV>
                end
            end
        else
            % `Theta` is already demeaned at this point.
            for jj = 1 : nDraw
                uuu(jj) = Theta(:,jj).' * invSgm * Theta(:,jj); %#ok<MINV>
            end
        end
    end % doUuu().

%**************************************************************************
    function doChkPosterFile()
        try
            valid = true;
            % Parameter list.
            paramList = h5readatt(inpFile,'/','paramList');
            paramList = regexp(paramList,'\w+','match');
            valid = valid && isequal(paramList,This.paramList);
            % Number of draws.
            nDraw = h5readatt(inpFile,'/','nDraw');
            % Save every.
            saveEvery = h5readatt(inpFile,'/','saveEvery');
            % Theta dataset.
            thetaInfo = h5info(inpFile,'/theta');
            valid = valid && nDraw == thetaInfo.Dataspace.Size(2);
            % Log posterior dataset.
            logPostInfo = h5info(inpFile,'/logPost');
            valid = valid && nDraw == logPostInfo.Dataspace.Size(2);
        catch
            valid = false;
        end
        if ~valid
            utils.error('poster', ...
                'This is not a valid posterior simulation file: ''%s''.', ...
                inpFile);
        end
    end % doChkPosterFiles().

%**************************************************************************
    function doOutpOpt()
        if ~isempty(opt.output)
            utils.warning('poster', ...
                ['This is an obsolete way of requesting output characteristics ',...
                'from stats(). See help for more information.']);
            output = opt.output;
            if ischar(output)
                output = regexp(output,'\w+','match');
            end            
            output = strrep(output,'prctile','prctile');
            list = {'chain','cov','mean','median','mode','mdd','std', ...
                'bounds','ksdensity'};
            for ii = 1 : length(list)
                opt.(list{ii}) = any(strcmpi(list{ii},output));
            end
            if any(strcmpi(output,'prctile'))
                if isempty(opt.prctile)
                    opt.prctile = [10,90];
                end
            else
                opt.prctile = [];
            end
            if any(strcmpi(output,'hpdi'))
                opt.hpdi = opt.hpdicover;
            else
                opt.hpdi = [];
            end
            if any(strcmpi(output,'hist'))
                opt.hist = opt.histbins;
            else
                opt.hist = [];
            end
        else
            if isequal(opt.prctile,true)
                opt.prctile = [10,90];
            end
            if isequal(opt.hpdi,true)
                opt.hpdi = 90;
            end
            if isequal(opt.hist,true)
                opt.hist = 50;
            end
        end
    end % doOutpOpt().

end