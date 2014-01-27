function This = myd2s(This,options)
% myd2s  [Not a public function] Create derivative-to-system convertor.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

occur = This.occur;
if issparse(occur)
    occur = reshape(full(occur), ...
        [size(occur,1),length(This.name),size(occur,2)/length(This.name)]);
end

ny = sum(This.nametype == 1);
nxx = sum(This.nametype == 2);
ne = sum(This.nametype == 3);
n = ny + nxx + ne;
t = This.tzero;

% Find max lag, minShift, and max lead, maxShift, for each transition
% variable.
minShift = zeros(1,nxx);
maxShift = zeros(1,nxx);
isNonlin = any(This.nonlin);
for i = 1 : nxx
    findOccur = find(any(occur(This.eqtntype == 2,ny+i,:),1)) - t;
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
                any(occur(This.eqtntype == 2 & This.nonlin,ny+i,:),1) ...
                ) - t);
            if maxOccur == maxShift(i)
                maxShift(i) = maxShift(i) + 1;
            end
        end
    end
    % If x(t-k) occurs in measurement equations then add k-1 lag.
    findOccur = find(any(occur(This.eqtntype == 1,ny+i,:),1)) -  t;
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
This.systemid{1} = find(This.nametype == 1);
This.systemid{3} = find(This.nametype == 3);
This.systemid{2} = zeros(1,0);
for k = max(maxShift) : -1 : min(minShift)
    % Add transition variables with this shift.
    This.systemid{2} = [This.systemid{2}, ...
        ny+find(k >= minShift & k < maxShift) + 1i*k];
end

nx = length(This.systemid{2});
nu = sum(imag(This.systemid{2}) >= 0);
np = nx - nu;

% Pre-allocate vectors of positions in derivative matrices
%----------------------------------------------------------
This.d2s.y_ = zeros(1,0);
This.d2s.xu1_ = zeros(1,0);
This.d2s.xu_ = zeros(1,0);
This.d2s.xp1_ = zeros(1,0);
This.d2s.xp_ = zeros(1,0);
This.d2s.e_ = zeros(1,0);

% Pre-allocate vectors of positions in unsolved system matrices
%---------------------------------------------------------------
This.d2s.y = zeros(1,0);
This.d2s.xu1 = zeros(1,0);
This.d2s.xu = zeros(1,0);
This.d2s.xp1 = zeros(1,0);
This.d2s.xp = zeros(1,0);
This.d2s.e = zeros(1,0);

% Transition variables
%----------------------
This.d2s.y_ = (t-1)*n + find(This.nametype == 1);
This.d2s.y = 1 : ny;

% Delete double occurences. These emerge whenever a variable has maxshift >
% 0 and minshift < 0.
This.d2s.remove = false(1,nu);
for i = 1 : nu
    This.d2s.remove(i) = ...
        any(This.systemid{2}(i)-1i == This.systemid{2}(nu+1:end)) ...
        || (options.removeleads && imag(This.systemid{2}(i)) > 0);
end

% Unpredetermined variables
%---------------------------
for i = 1 : nu
    id = This.systemid{2}(i);
    if imag(id) == minShift(real(id)-ny)
        This.d2s.xu_(end+1) = (imag(id)+t-1)*n + real(id);
        This.d2s.xu(end+1) = i;
    end
    This.d2s.xu1_(end+1) = (imag(id)+t+1-1)*n + real(id);
    This.d2s.xu1(end+1) = i;
end

% Predetermined variables
%-------------------------
for i = 1 : np
    id = This.systemid{2}(nu+i);
    if imag(id) == minShift(real(id)-ny)
        This.d2s.xp_(end+1) = (imag(id)+t-1)*n + real(id);
        This.d2s.xp(end+1) = nu + i;
    end
    This.d2s.xp1_(end+1) = (imag(id)+t+1-1)*n + real(id);
    This.d2s.xp1(end+1) = nu + i;
end

% Shocks
%--------
This.d2s.e_ = (t-1)*n + find(This.nametype == 3);
This.d2s.e = 1 : ne;

% Dynamic identity matrices
%---------------------------
This.d2s.ident1 = zeros(0,nx);
This.d2s.ident = zeros(0,nx);
for i = 1 : nx
    id = This.systemid{2}(i);
    if imag(id) ~= minShift(real(id)-ny)
        aux = zeros(1,nx);
        aux(This.systemid{2} == id-1i) = 1;
        This.d2s.ident1(end+1,1:end) = aux;
        aux = zeros(1,nx);
        aux(i) = -1;
        This.d2s.ident(end+1,1:end) = aux;
    end
end

% Solution IDs.
nx = length(This.systemid{2});
nb = sum(imag(This.systemid{2}) < 0);
nf = nx - nb;

This.solutionid = {...
    This.systemid{1},...
    [This.systemid{2}(~This.d2s.remove),1i+This.systemid{2}(nf+1:end)],...
    This.systemid{3},...
    };

This.solutionvector = { ...
    myvector(This,'y'), ...
    myvector(This,'x'), ...
    myvector(This,'e'), ...
    };

end