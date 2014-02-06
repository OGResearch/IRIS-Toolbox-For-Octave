function [S,Range,Select] = myrf(This,Time,Func,Select,Opt)
% myrf  [Not a public function] Response function backend.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Parse required input arguments.
pp = inputParser();
if ismatlab
pp.addRequired('M',@(x) isa(This,'model'));
pp.addRequired('TIME',@isnumeric);
pp.parse(This,Time);
else
pp = pp.addRequired('M',@(x) isa(This,'model'));
pp = pp.addRequired('TIME',@isnumeric);
pp = pp.parse(This,Time);
end

% Tell whether time is nper or range.
if length(Time) == 1 && round(Time) == Time && Time > 0
    Range = 1 : Time;
else
    Range = Time(1) : Time(end);
end
nPer = length(Range);

%--------------------------------------------------------------------------

ny = sum(This.nametype == 1);
nx = size(This.solution{1},1);
nAlt = size(This.Assign,3);
nRun = length(Select);

% Simulate response function
%----------------------------
% Output data from `timedom.srf` and `timedom.icrf` include the pre-sample
% period.
Phi = nan(ny+nx,nRun,nPer+1,nAlt);

isSolution = true(1,nAlt);
for iAlt = 1 : nAlt
    [T,R,K,Z,H,D,U] = mysspace(This,iAlt,false); %#ok<ASGLU>
    
    % Continue immediately if solution is not available.
    isSolution(iAlt) = all(~isnan(T(:)));
    if ~isSolution(iAlt)
        continue
    end    
    
    Phi(:,:,:,iAlt) = Func(T,R,[],Z,H,[],U,[],iAlt,nPer);
end

% Report NaN solutions.
if ~all(isSolution)
    utils.warning('model', ...
        'Solution(s) not available:%s.', ...
        preparser.alt2str(~isSolution));
end

% Create output data
%--------------------
S = struct();
maxLag = -min(imag(This.solutionid{2}));

% Permute Phi so that Phi(k,t,m,n) is the response of the k-th variable to
% m-th init condition at time t in parameterisation n.
Phi = permute(Phi,[1,3,2,4]);

template = tseries();
comment = repmat(Select,[1,1,nAlt]);

% Measurement variables.
Y = Phi(1:ny,:,:,:);
for i = find(This.nametype == 1)
    y = permute(Y(i,:,:,:),[2,3,4,1]);
    if Opt.delog && This.log(i)
        y = exp(y);
    end
    name = This.name{i};
    c = regexprep(comment,'.*',[name,' <-- $0'],'once');
    S.(name) = replace(template,y,Range(1)-1,c);
end

% Transition variables.
X = myreshape(This,Phi(ny+1:end,:,:,:));
offset = sum(This.nametype == 1);
for i = find(This.nametype == 2)
    x = permute(X(i-offset,:,:,:),[2,3,4,1]);
    if Opt.delog && This.log(i)
        x = exp(x);
    end
    name = This.name{i};
    c = regexprep(comment,'.*',[name,' <-- $0'],'once');
    S.(name) = replace(template,x,Range(1)-1-maxLag,c);
end

% Shocks.
e = zeros(nPer,nRun,nAlt);
for i = find(This.nametype == 3)
    name = This.name{i};    
    c = regexprep(comment,'.*',[name,' <-- $0'],'once');
    S.(name) = replace(template,e,Range(1),c);
end

% Parameters.
for i = find(This.nametype == 4)
    S.(This.name{i}) = permute(This.Assign(1,i,:),[1,3,2]);
end

end