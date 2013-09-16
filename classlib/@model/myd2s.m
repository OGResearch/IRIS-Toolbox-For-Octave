function m = myd2s(m,options)
% myd2s  [Not a public function] Create derivative-to-system convertor.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

occur = m.occur;
if issparse(occur)
    occur = reshape(full(occur), ...
        [size(occur,1),length(m.name),size(occur,2)/length(m.name)]);
end

ny = sum(m.nametype == 1);
nxx = sum(m.nametype == 2);
ne = sum(m.nametype == 3);
n = ny + nxx + ne;
t = m.tzero;

% Find max lag, minShift, and max lead, maxShift, for each transition
% variable.
minShift = zeros(1,nxx);
maxShift = zeros(1,nxx);
isNonlin = any(m.nonlin);
for i = 1 : nxx
    findOccur = find(any(occur(m.eqtntype == 2,ny+i,:),1)) - t;
    findOccur = findOccur(:).';
    if ~isempty(findOccur)
        minShift(i) = min([minShift(i),findOccur]);
        maxShift(i) = max([maxShift(i),findOccur]);
        % User requests adding one lead to all fwl variables.
        if options.addlead && maxShift(i) > 0
            maxShift(i) = maxShift(i) + 1;
        end
        % Add one lead to fwl variables in equations earmarked for non-linear
        % simulations if the max lead of that variabl occurs in one of those
        % equations.
        if isNonlin && maxShift(i) > 0
            maxOccur = max(find( ...
                any(occur(m.eqtntype == 2 & m.nonlin,ny+i,:),1) ...
                ) - t);
            if maxOccur == maxShift(i)
                maxShift(i) = maxShift(i) + 1;
            end
        end
    end
    % If x(t-k) occurs in measurement equations then add k-1 lag.
    findOccur = find(any(occur(m.eqtntype == 1,ny+i,:),1)) -  t;
    findOccur = findOccur(:).';
    if ~isempty(findOccur)
        minShift(i) = min([minShift(i),min(findOccur)-1]);
    end
    % If `minShift(i) == maxShift(i) == 0`, the variable is static, treat it as
    % forward-looking to reduce state space, and to guarantee that all
    % variables will have `maxShift > minShift`.
    if minShift(i) == maxShift(i)
        maxShift(i) = 1;
    end
end

% System IDs. These will be used to construct solution IDs.
m.systemid{1} = find(m.nametype == 1);
m.systemid{3} = find(m.nametype == 3);
m.systemid{2} = zeros(1,0);
for k = max(maxShift) : -1 : min(minShift)
    % Add transition variables with this shift.
    m.systemid{2} = [m.systemid{2}, ...
        ny+find(k >= minShift & k < maxShift) + 1i*k];
end

nx = length(m.systemid{2});
nu = sum(imag(m.systemid{2}) >= 0);
np = nx - nu;

% Pre-allocate vectors of positions in derivative matrices
%----------------------------------------------------------
m.d2s.y_ = zeros(1,0);
m.d2s.xu1_ = zeros(1,0);
m.d2s.xu_ = zeros(1,0);
m.d2s.xp1_ = zeros(1,0);
m.d2s.xp_ = zeros(1,0);
m.d2s.e_ = zeros(1,0);

% Pre-allocate vectors of positions in unsolved system matrices
%---------------------------------------------------------------
m.d2s.y = zeros(1,0);
m.d2s.xu1 = zeros(1,0);
m.d2s.xu = zeros(1,0);
m.d2s.xp1 = zeros(1,0);
m.d2s.xp = zeros(1,0);
m.d2s.e = zeros(1,0);

% Transition variables
%----------------------
m.d2s.y_ = (t-1)*n + find(m.nametype == 1);
m.d2s.y = 1 : ny;

% Delete double occurences. These emerge whenever a variable has maxshift >
% 0 and minshift < 0.
m.d2s.remove = false(1,nu);
for i = 1 : nu
    m.d2s.remove(i) = ...
        any(m.systemid{2}(i)-1i == m.systemid{2}(nu+1:end)) ...
        || (options.removeleads && imag(m.systemid{2}(i)) > 0);
end

% Unpredetermined variables
%---------------------------
for i = 1 : nu
    id = m.systemid{2}(i);
    if imag(id) == minShift(real(id)-ny)
        m.d2s.xu_(end+1) = (imag(id)+t-1)*n + real(id);
        m.d2s.xu(end+1) = i;
    end
    m.d2s.xu1_(end+1) = (imag(id)+t+1-1)*n + real(id);
    m.d2s.xu1(end+1) = i;
end

% Predetermined variables
%-------------------------
for i = 1 : np
    id = m.systemid{2}(nu+i);
    if imag(id) == minShift(real(id)-ny)
        m.d2s.xp_(end+1) = (imag(id)+t-1)*n + real(id);
        m.d2s.xp(end+1) = nu + i;
    end
    m.d2s.xp1_(end+1) = (imag(id)+t+1-1)*n + real(id);
    m.d2s.xp1(end+1) = nu + i;
end

% Shocks
%--------
m.d2s.e_ = (t-1)*n + find(m.nametype == 3);
m.d2s.e = 1 : ne;

% Dynamic identity matrices
%---------------------------
m.d2s.ident1 = zeros(0,nx);
m.d2s.ident = zeros(0,nx);
for i = 1 : nx
    id = m.systemid{2}(i);
    if imag(id) ~= minShift(real(id)-ny)
        aux = zeros(1,nx);
        aux(m.systemid{2} == id-1i) = 1;
        m.d2s.ident1(end+1,1:end) = aux;
        aux = zeros(1,nx);
        aux(i) = -1;
        m.d2s.ident(end+1,1:end) = aux;
    end
end

% Solution IDs.
nx = length(m.systemid{2});
nb = sum(imag(m.systemid{2}) < 0);
nf = nx - nb;

m.solutionid = {...
    m.systemid{1},...
    [m.systemid{2}(~m.d2s.remove),1i+m.systemid{2}(nf+1:end)],...
    m.systemid{3},...
    };

m.solutionvector = { ...
    myvector(m,'y'), ...
    myvector(m,'x'), ...
    myvector(m,'e'), ...
    };

end