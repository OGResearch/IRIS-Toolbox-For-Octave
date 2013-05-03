function varargout = mysimulate(This,Caller,Draw,Opt)
% mysimulate  [Not a public function] Posterior simulator engine.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team & Troy Matheson.

% This function can be called either by `arwm` to draw a chain from the
% posterior distribution, or by `eval` to evaluate the posterior density at
% a particular point.

%--------------------------------------------------------------------------

% Prepackage options.
s = struct();
s.lowerBounds = This.lowerBounds(:);
s.upperBounds = This.upperBounds(:);
s.lowerBoundsPos = s.lowerBounds > -Inf;
s.upperBoundsPos = s.upperBounds < Inf;
s.lowerBounds = s.lowerBounds(s.lowerBoundsPos);
s.upperBounds = s.upperBounds(s.upperBoundsPos);
s.chkBounds = any(s.lowerBoundsPos) || any(s.upperBoundsPos);
s.isMinusLogPostFunc = isa(This.minusLogPostFunc,'function_handle');
if ~s.isMinusLogPostFunc
    s.priorIndex = cellfun(@isfunc,This.logPriorFunc);
end

switch Caller
    case 'arwm'
        Theta = [];
        LogPost = [];
        AccRatio = [];
        Sgm = [];
        FinalCov = [];
        doArwm();
        varargout{1} = Theta;
        varargout{2} = LogPost;
        varargout{3} = AccRatio;
        varargout{4} = Sgm;
        varargout{5} = FinalCov;
        varargout{6} = SaveCount;
    %case 'impsamp'
    %    doimpsamp();
    case 'eval'
        doEval();
        varargout{1} = Obj;
        varargout{2} = L;
        varargout{3} = PP;
        varargout{4} = SP;
end

% Nested functions.

%**************************************************************************
    function doEval()
        % doEval  Evaluate log posterior at specified points.
        if ~iscell(Draw)
            Draw = {Draw};
        end
        nDraw = numel(Draw);
        % Minus log posterior.
        Obj = nan(size(Draw));
        % Minus log likelihood.
        L = nan(size(Draw));
        % Minus log parameter priors.
        PP = nan(size(Draw));
        % Minus log system priors.
        SP = nan(size(Draw));
        for i = 1 : nDraw
            theta = Draw{i}(:);
            [Obj(i),L(i),PP(i),SP(i)] = mylogpost(This,theta,s);
        end
    end % doEval().

%**************************************************************************
    function doArwm()
        
        % Number of estimated parameters.
        nPar = length(This.paramList);
        
        % Adaptive random walk Metropolis simulator.
        nAlloc = min(Draw,Opt.saveevery);
        isSave = Opt.saveevery <= Draw;
        if isSave
            doChkSaveOptions();
        end
        
        sgm = Opt.initscale;
        if Opt.burnin < 1
            % Burn-in is a percentage.
            burnin = round(Opt.burnin*Draw);
        else
            % Burn-in is a number of draws.
            burnin = Opt.burnin;
        end
        
        nDraw = Draw + burnin;
        gamma = Opt.gamma;
        k1 = Opt.adaptscale;
        k2 = Opt.adaptproposalcov;
        targetAR = Opt.targetar;
        
        isAdaptiveScale = isfinite(gamma) && k1 > 0;
        isAdaptiveShape = isfinite(gamma) && k2 > 0;
        isAdaptive = isAdaptiveScale || isAdaptiveShape;
        
        theta = This.initParam(:);
        P = chol(This.initProposalCov).';
        logPost = mylogpost(This,theta,s);
        
        % Pre-allocate output data.
        Theta = zeros(nPar,nAlloc);
        LogPost = zeros(1,nAlloc);
        AccRatio = zeros(1,nAlloc);
        if isAdaptiveScale
            Sgm = zeros(1,nAlloc);
        else
            Sgm = sgm;
        end
        
        if Opt.progress
            progress = progressbar('IRIS poster.arwm progress');
        elseif Opt.esttime
            eta = esttime('IRIS poster.arwm is running');
        end
        
        % Main loop.
        nAccepted = 0;
        count = 0;
        SaveCount = 0;
        for j = 1 : nDraw
            % Propose a new theta.
            u = randn(nPar,1);
            newTheta = theta + sgm*P*u;
            
            % Evaluate log posterior.
            newLogPost = mylogpost(This,newTheta,s);
            
            % Prob of new proposal being accepted.
            alpha = min(1,exp(newLogPost-logPost));
            % Decide if we accept the new theta.
            accepted = rand() <= alpha;
            if accepted
                logPost = newLogPost;
                theta = newTheta;
            end
            % Adapt the scale and/or proposal covariance.
            if isAdaptive
                nu = j^(-gamma);
                phi = nu*(alpha - targetAR);
                if isAdaptiveScale
                    phi1 = k1*phi;
                    sgm = exp(log(sgm) + phi1);
                end
                if isAdaptiveShape
                    phi2 = k2*phi;
                    unorm2 = u.'*u;
                    z = sqrt(phi2/unorm2)*u;
                    P = cholupdate(P.',P*z).';
                end
            end
            % Add the j-th theta to the chain unless it's burn-in sample.
            if j > burnin
                count = count + 1;
                nAccepted = nAccepted + double(accepted);
                % Paremeter draws.
                Theta(:,count) = theta;
                % Value of log posterior at the current draw.
                LogPost(count) = logPost;
                % Acceptance ratio so far.
                AccRatio(count) = nAccepted / (j-burnin);
                % Adaptive scale factor.
                if isAdaptiveScale
                    Sgm(count) = sgm;
                end
                if count == Opt.saveevery ...
                        || (isSave && j == nDraw)
                    count = 0;
                    doSave();
                end
            end
            % Update the progress bar or estimated time.
            if Opt.progress
                update(progress,j/nDraw);
            elseif Opt.esttime
                update(eta,j/nDraw);
            end
        end
        
        FinalCov = P*P.';
        
        if isSave
            % Save master file with the following information
            % * `PList` -- list of estimated parameters;
            % * `SaveCount` -- the total number of files;
            % * `Draw` -- the total number of draws;
            PList = This.paramList; %#ok<NASGU>
            save(Opt.saveas,'PList','SaveCount','Draw');
        end
        
        function doChkSaveOptions()
            if isempty(Opt.saveas)
                utils.error('poster', ...
                    'The option ''saveas='' must be a valid file name.');
            end
            [p,t] = fileparts(Opt.saveas);
            Opt.saveas = fullfile(p,t);
        end % doChkSaveOptions().
        
        function doSave()
            SaveCount = SaveCount + 1;
            filename = [Opt.saveas,sprintf('%g',SaveCount)];
            save(filename,'Theta','LogPost','-v7.3');
            togo = nDraw-j;
            if togo == 0
                Theta = [];
                LogPost = [];
                AccRatio = [];
                Sgm = [];
            elseif togo < nAlloc
                Theta = Theta(:,1:togo);
                LogPost = LogPost(1:togo);
                AccRatio = AccRatio(1:togo);
                if isAdaptiveScale
                    Sgm = Sgm(1:togo);
                end
            end
        end % doSave().
        
    end % doArwm().

end