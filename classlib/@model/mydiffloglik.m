function [MLL,Score,Info,Se2] = mydiffloglik(This,Data,Pri,LikOpt,Opt)
% mydiffloglik  [Not a public function] Gradient and hessian of log-likelihood function.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if ~isfield(Opt,'progress')
    Opt.progress = false;
end

if ~isfield(Opt,'percent')
    Opt.percent = false;
end

% Initialise steady-state solver and chksstate options.
Opt.sstate = mysstateopt(This,'silent',Opt.sstate);
Opt.chksstate = mychksstateopt(This,Opt.chksstate);

%--------------------------------------------------------------------------

assignpos = Pri.assignpos;
stdcorrpos = Pri.stdcorrpos;

ny = sum(This.nametype == 1);

np = length(assignpos);
[~,nPer,nData] = size(Data);

MLL = zeros(1,nData);
Score = zeros(1,np,nData);
Info = zeros(np,np,nData);
Se2 = zeros(1,nData);

p = nan(1,np);
assignNan = isnan(assignpos);
stdcorrNan = isnan(stdcorrpos);
p(~assignNan) = This.Assign(1,assignpos(~assignNan));
p(~stdcorrNan) = This.stdcorr(1,stdcorrpos(~stdcorrNan));

epsilon = eps()^(1/3);
step = max([abs(p);ones(size(p))],[],1)*epsilon;
twoSteps = nan(1,np);

% Create all parameterisations.
This(1:2*np+1) = This;
for i = 1 : np
    pp = p;
    mp = p;
    pp(i) = pp(i) + step(i);
    mp(i) = mp(i) - step(i);
    twoSteps(i) = pp(i) - mp(i);
    mInx = 1 + 2*(i-1) + 1;
    This(mInx) = myupdatemodel(This(mInx),pp,Pri,Opt,true);
    mInx = 1 + 2*(i-1) + 2;
    This(mInx) = myupdatemodel(This(mInx),mp,Pri,Opt,true);
end

% Horizontal vectorisation.
vechor = @(x) x(:)';

if Opt.progress
    % Create progress bar.
    progress = progressbar('IRIS model.diffloglik progress');
end

for iData = 1 : nData
    doDomainLoop();
end

% Nested functions.

%**************************************************************************
    function doDomainLoop()
        
        dpe = cell(1,np);
        dpe(:) = {nan(ny,nPer)};
        
        Fi_pe = zeros(ny,nPer);
        X = zeros(ny);
        
        Fi_dpe = cell(1,np);
        Fi_dpe(1:np) = {nan(ny,nPer)};
        
        dF = cell(1,np);
        dF(:) = {nan(ny,ny,nPer)};
        
        dFvec = cell(1,np);
        dFvec(:) = {[]};
        
        Fi_dF = cell(1,np);
        Fi_dF(:) = {nan(ny,ny,nPer)};

        % Call the Kalman filter.
        [MLL(iData),Y] = mykalman(This(1),Data(:,:,iData),[],LikOpt);        
        Se2(iData) = Y.V;
        F = Y.F(:,:,2:end);
        pe = Y.Pe(:,2:end);
        Fi = F;
        for ii = 1 : size(Fi,3)
            j = ~all(isnan(Fi(:,:,ii)),1);
            Fi(j,j,ii) = inv(Fi(j,j,ii));
        end
        
        for ii = 1 : np
            pm = This(1+2*(ii-1)+1);
            [~,Y] = mykalman(pm,Data(:,:,iData),[],LikOpt);
            pF =  Y.F(:,:,2:end);
            ppe = Y.Pe(:,2:end);
            
            mm = This(1+2*(ii-1)+2);
            [~,Y] = mykalman(mm,Data(:,:,iData),[],LikOpt);
            mF =  Y.F(:,:,2:end);
            mpe = Y.Pe(:,2:end);
            
            dF{ii}(:,:,:) = (pF - mF) / twoSteps(ii);
            dpe{ii}(:,:) = (ppe - mpe) / twoSteps(ii);
        end
        
        for t = 1 : nPer
            o = ~isnan(pe(:,t));
            for ii = 1 : np
                Fi_dF{ii}(o,o,t) = Fi(o,o,t)*dF{ii}(o,o,t);
            end
        end
        
        for t = 1 : nPer
            o = ~isnan(pe(:,t));
            for ii = 1 : np
                temp = dF{ii}(o,o,t);
                dFvec{t}(:,ii) = temp(:);
                for jj = 1 : ii
                    % Info(i,j,idata) =  ...
                    %     Info(i,j,idata) ...
                    %     + 0.5*trace(Fi_dF{i}(o,o,t)*Fi_dF{j}(o,o,t)) ...
                    %     + (transpose(dpe{i}(o,t))*Fi_dpe{j}(o,t));
                    % * the first term is data independent
                    % * trace A*B = vechor(A')*vec(B)
                    Xi = transpose(Fi_dF{ii}(o,o,t));
                    Xi = transpose(Xi(:));
                    Xj = Fi_dF{jj}(o,o,t);
                    Xj = Xj(:);
                    Info(ii,jj,iData) = Info(ii,jj,iData) + Xi*Xj/2;
                end
            end
        end
        
        % Score vector.
        for t = 1 : nPer
            o = ~isnan(pe(:,t));
            Fi_pe(o,t) = Fi(o,o,t)*pe(o,t);
            X(o,o,t) = eye(sum(o)) - Fi_pe(o,t)*transpose(pe(o,t));
            dpevec = [];
            for ii = 1 : np
                dpevec = [dpevec,dpe{ii}(o,t)]; %#ok<AGROW>
                Fi_dpe{ii}(o,t) = Fi(o,o,t)*dpe{ii}(o,t);
            end
            Score(1,:,iData) = Score(1,:,iData) ...
                + vechor(Fi(o,o,t)*transpose(X(o,o,t)))*dFvec{t}/2 ...
                + transpose(Fi_pe(o,t))*dpevec;
        end
        
        % Information matrix.
        for t = 1 : nPer
            o = ~isnan(pe(:,t));
            for ii = 1 : np
                for jj = 1 : ii
                    % Info(i,j,idata) =
                    %     Info(i,j,idata)
                    %     + 0.5*trace(Fi_dF{i}(o,o,t)*Fi_dF{j}(o,o,t))
                    %     + (transpose(dpe{i}(o,t))*Fi_dpe{j}(o,t));
                    % first term is data-independent and has been pre-computed.
                    Info(ii,jj,iData) = Info(ii,jj,iData) ...
                        + (transpose(dpe{ii}(o,t))*Fi_dpe{jj}(o,t));
                end
            end
        end
        
        Info(:,:,iData) = Info(:,:,iData) + transpose(tril(Info(:,:,iData),-1));
        
        if Opt.progress
            % Update progress bar.
            update(progress,iData/nData);
        end
        
    end

end