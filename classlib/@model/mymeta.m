function m = mymeta(m,options)
% mymeta  [Not a public function] Create model-specific meta data.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

occur = m.occur;
if issparse(occur)
    occur = ...
        reshape(full(occur), ...
        [size(occur,1),length(m.name),size(occur,2)/length(m.name)]);
end

nm = sum(m.nametype == 1);
nt = sum(m.nametype == 2);
ns = sum(m.nametype == 3);
n = nm + nt + ns;
t = m.tzero;

% Find max lag (minshift) and max lead (maxshift) for each transition
% variable.
minShift = zeros(1,nt);
maxShift = zeros(1,nt);
isNonlin = any(m.nonlin);
for i = 1 : nt
    findOccur = find(any(occur(m.eqtntype == 2,nm+i,:),1)) - t;
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
                any(occur(m.eqtntype == 2 & m.nonlin,nm+i,:),1) ...
                ) - t);
            if maxOccur == maxShift(i)
                maxShift(i) = maxShift(i) + 1;
            end
        end
    end
    % If x(t-k) occurs in measurement equations
    % then add k-1 lag.
    findOccur = find(any(occur(m.eqtntype == 1,nm+i,:),1)) -  t;
    findOccur = findOccur(:).';
    if ~isempty(findOccur)
        minShift(i) = min([minShift(i),min(findOccur)-1]);
    end
    % If minshift(i) == maxshift(i) == 0 the variables is static, consider
    % it forward-looking to reduce state space. This also guarantees that
    % all variables will have maxshift > minshift.
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
        nm+find(k >= minShift & k < maxShift) + 1i*k];
end

nx = length(m.systemid{2});
nu = sum(imag(m.systemid{2}) >= 0);
np = nx - nu;

m.metaderiv.y = zeros(1,0);
m.metaderiv.uplus = zeros(1,0);
m.metaderiv.u = zeros(1,0);
m.metaderiv.pplus = zeros(1,0);
m.metaderiv.p = zeros(1,0);
m.metaderiv.e = zeros(1,0);

m.metasystem.y = zeros(1,0);
m.metasystem.uplus = zeros(1,0);
m.metasystem.u = zeros(1,0);
m.metasystem.pplus = zeros(1,0);
m.metasystem.p = zeros(1,0);
m.metasystem.e = zeros(1,0);

m.metaderiv.y = (t-1)*n + find(m.nametype == 1);
m.metasystem.y = 1 : nm;

m.systemident.xplus = zeros(0,nx);
m.systemident.x = zeros(0,nx);

% Delete double occurences. These emerge whenever a variable has maxshift >
% 0 and minshift < 0.
m.metadelete = false(1,nu);
for i = 1 : nu
    if any(m.systemid{2}(i)-1i == m.systemid{2}(nu+1:end)) ...
            || (options.removeleads && imag(m.systemid{2}(i)) > 0)
        m.metadelete(i) = true;
    end
end

for i = 1 : nu
    id = m.systemid{2}(i);
    if imag(id) == minShift(real(id)-nm)
        m.metaderiv.u(end+1) = (imag(id)+t-1)*n + real(id);
        m.metasystem.u(end+1) = i;
    end
    m.metaderiv.uplus(end+1) = (imag(id)+t+1-1)*n + real(id);
    m.metasystem.uplus(end+1) = i;
end

for i = 1 : np
    id = m.systemid{2}(nu+i);
    if imag(id) == minShift(real(id)-nm)
        m.metaderiv.p(end+1) = (imag(id)+t-1)*n + real(id);
        m.metasystem.p(end+1) = i;
    end
    m.metaderiv.pplus(end+1) = (imag(id)+t+1-1)*n + real(id);
    m.metasystem.pplus(end+1) = i;
end

m.metaderiv.e = (t-1)*n + find(m.nametype == 3);
m.metasystem.e = 1 : ns;

for i = 1 : nu+np
    id = m.systemid{2}(i);
    if imag(id) ~= minShift(real(id)-nm)
        aux = zeros(1,nu+np);
        aux(m.systemid{2} == id-1i) = 1;
        m.systemident.xplus(end+1,1:end) = aux;
        aux = zeros(1,nu+np);
        aux(i) = -1;
        m.systemident.x(end+1,1:end) = aux;
    end
end

% Solution IDs.
nx = length(m.systemid{2});
nb = sum(imag(m.systemid{2}) < 0);
nf = nx - nb;

m.solutionid = {...
    m.systemid{1},...
    [m.systemid{2}(~m.metadelete),1i+m.systemid{2}(nf+1:end)],...
    m.systemid{3},...
    };

m.solutionvector = { ...
    myvector(m,'y'), ...
    myvector(m,'x'), ...
    myvector(m,'e'), ...
    };

end