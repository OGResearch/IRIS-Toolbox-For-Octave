function [S,ExitFlag,Discrep,AddFact] = nonlinear(S,Opt)
% nonlinear  [Not a public function] Split non-linear simulation into segments of unanticipated
% shocks, and simulate one segment at a time.
%
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(S.Z,1);
nx = size(S.T,1);
nb = size(S.T,2);
nf = nx - nb;
ne = size(S.e,1);
nPer = size(S.e,2);
lambda0 = Opt.lambda;
nn = sum(S.nonlin);

S0 = S;

% Store anticipated and unanticipated shocks outside S and remove them from
% S; they will be supplied in S for a segment specific range in each step.
ea = S.antFunc(S.e);
eu = S.unantFunc(S.e);
lastEA = utils.findlast(ea);
S.e = [];

nPerMax = max([nPer,S.segment(end)+S.npernonlin-1]);

% Store all anchors outside S and remove them from S; they will be supplied
% in S for a segment specific range in each step.
yAnchors = S.yAnchors;
xAnchors = S.xAnchors;
eAAnchors = S.eaanchors;
eUAnchors = S.euanchors;
weightsA = S.weightsA;
weightsU = S.weightsU;
yTune = S.ytune;
xTune = S.xtune;
isAAnchors = any(eAAnchors(:) ~= 0);
isUAnchors = any(eUAnchors(:) ~= 0);

S.yAnchors = [];
S.xAnchors = [];
S.eaanchors = [];
S.euanchors = [];
S.weightsA = [];
S.weightsU = [];
S.ytune = [];
S.xtune = [];

% If the last simulated period in the last segment goes beyond nper, we
% expand the below arrays accordingly, so that it is easier to set up their
% segment-specific version in S.
if nPer < nPerMax
    ea(:,end+1:nPerMax) = 0;
    eu(:,end+1:nPerMax) = 0;
    if isAAnchors || isUAnchors
        yAnchors(:,end+1:nPerMax) = false;
        xAnchors(:,end+1:nPerMax) = false;
        eAAnchors(:,end+1:nPerMax) = false;
        eUAnchors(:,end+1:nPerMax) = false;
        weightsA(:,end+1:nPerMax) = 0;
        weightsU(:,end+1:nPerMax) = 0;
        yTune(:,end+1:nPerMax) = NaN;
        xTune(:,end+1:nPerMax) = NaN;
    end
end

y = zeros(ny,0);
w = zeros(nx,0);
e = zeros(ne,0);
S.u = zeros(nn,0);
nSegment = length(S.segment);

ExitFlag = zeros(1,nSegment);
AddFact = nan(nn,nPerMax,nSegment);
Discrep = nan(nn,nPer);

for iSegment = 1 : nSegment
    % The segment dates are defined by `first` to `last`, a total of `nper1`
    % periods. These are the dates that will be added to the output data.
    % However, the actual range to be simulated can be longer because
    % `lastnonlin` (the number of non-linearised periods) may go beyond `last`.
    % The number of periods simulated is therefore `nper1max`.
    first = S.segment(iSegment);
    if iSegment < nSegment
        lastRep = S.segment(iSegment+1) - 1;
    else
        lastRep = nPer;
    end
    % Last period simulated in a non-linear mode.
    lastNonlin = first + S.npernonlin - 1;
    % Last period simulated.
    lastSim = max([lastRep,lastNonlin,lastEA]);
    % Number of periods reported in the final output data.
    nPerRep = lastRep - first + 1;
    % Number of periods simulated.
    nPerSim = lastSim - first + 1;
    nPerChopOff = min(nPerRep,S.npernonlin);
    
    % Prepare shocks: Combine anticipated shocks on the whole segment with
    % unanticipated shocks in the initial period.
    S.e = S.auFunc( ...
        ea(:,first:lastSim), ...
        [eu(:,first),zeros(ne,nPerSim-1)]);
    
    % Prepare anchors: Anticipated and unanticipated endogenised shocks cannot
    % be combined in non-linear simulations. If there is no anchors, we can
    % leave the fields empty.
    if isAAnchors
        S.yAnchors = yAnchors(:,first:lastSim);
        S.xAnchors = xAnchors(:,first:lastSim);
        S.eaanchors = eAAnchors(:,first:lastSim);
        S.euanchors = false(size(S.eaanchors));
        S.weightsA = weightsA(:,first:lastSim);
        S.weightsU = zeros(size(S.weightsA));
        S.ytune = yTune(:,first:lastSim);
        S.xtune = xTune(:,first:lastSim);
    elseif isUAnchors
        S.yAnchors = [yAnchors(:,first),false(ny,nPerSim-1)];
        S.xAnchors = [xAnchors(:,first),false(nx,nPerSim-1)];
        S.euanchors = [eUAnchors(:,first),false(ne,nPerSim-1)];
        S.eaanchors = false(size(S.euanchors));
        S.weightsU = [weightsU(:,first),zeros(ne,nPerSim-1)];
        S.weightsA = zeros(size(S.weightsU));
        S.ytune = [yTune(:,first),nan(ny,nPerSim-1)];
        S.xtune = [xTune(:,first),nan(nx,nPerSim-1)];
    end
    
    % Reset counters and flags.
    S.count = 0;
    S.stop = 0;
    S.lambda = lambda0;
    
    % Re-use addfactors from the previous segment.
    S.u(:,end+1:S.npernonlin) = 0;
    
    % Create segment string.
    s = sprintf('%g:%g[%g]#%g',...
        S.zerothSegment+first, ...
        S.zerothSegment+lastRep, ...
        S.zerothSegment+lastSim, ...
        S.npernonlin);
    S.segmentString = sprintf('%16s',s);
    
    % Simulate this segment
    %-----------------------
    S = simulate.segment(S,Opt);
    S = simulate.linear(S,nPerSim,Opt);
    
    % Store results in temporary arrays.
    y = [y,S.y(:,1:nPerRep)]; %#ok<AGROW>
    w = [w,S.w(:,1:nPerRep)]; %#ok<AGROW>
    e = [e,S.e(:,1:nPerRep)]; %#ok<AGROW>
    
    % Update initial condition for next segment.
    S.a0 = S.w(nf+1:end,nPerRep);
    
    % Report diagnostic output arguments.
    Discrep(:,first+(0:nPerChopOff-1)) = S.discrep(:,1:nPerChopOff);
    ExitFlag = [ExitFlag,S.stop]; %#ok<AGROW>
    AddFact(:,first+(0:size(S.u,2)-1),iSegment) = S.u;
    
    % Remove add-factors within the current segment's reported range. Any
    % add-factors going beyond the reported range end will be used as starting
    % values in the next segment. Note that `u` can be shorter than `nper1`.
    S.u(:,1:nPerChopOff) = [];
    
    % Update progress bar.
    if ~isempty(S.progress)
        update(S.progress, ...
            ((S.iLoop-1)*nSegment+iSegment)/(S.nLoop*nSegment));
    end
end

% Populate simulated data.
S.e = e;
S.y = y;
S.w = w;

% Restore fields temporarily deleted.
S.yAnchors = S0.yAnchors;
S.xAnchors = S0.xAnchors;
S.eaanchors = S0.eaanchors;
S.euanchors = S0.euanchors;
S.weightsA = S0.weightsA;
S.weightsU = S0.weightsU;
S.ytune = S0.ytune;
S.xtune = S0.xtune;

end