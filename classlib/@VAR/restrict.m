function [Rr,Qq] = restrict(Ny,Nk,Ng,Opt)
% restrict  [Not a public function] Convert parameter restrictions to hyperparameter matrix form.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%#ok<*CTCH>

%--------------------------------------------------------------------------

if isempty(Opt.constraints) ...
        && isempty(Opt.a) ...
        && isempty(Opt.c) ...
        && isempty(Opt.g)
    Rr = [];
    Qq = [];
end

if isnumeric(Opt.constraints)
    Rr = Opt.constraints;
    if nargout > 1
        Qq = xxRr2Qq(Rr);
    end
    return
end

nLag = Opt.order;
if Opt.diff
    nLag = nLag - 1;
end

nBeta = Ny*(Nk+Ny*nLag+Ng);
Q = zeros(0,nBeta);
q = zeros(0);

isPlain = ~isempty(Opt.a) ...
    || ~isempty(Opt.c) ...
    || ~isempty(Opt.g);

% General constraints.
rest = lower(strtrim(Opt.constraints));
if ~isempty(rest)
    rest = strfun.converteols(rest);
    rest = strrep(rest,char(10),' ');
    rest = lower(rest);
    % Convert char to cellstr: for bkw compatibility, char strings can use
    % semicolons to separate individual restrictions.
    if ischar(rest)
        % Replace semicolons outside brackets with &s.
        rest0 = rest;
        rest = strfun.strrepoutside(rest,';','&','[]','()');
        if ~isequal(rest,rest0)
            % ##### Feb 2014 OBSOLETE and scheduled for removal.
            utils.warning('VAR:restrict', ...
                ['Entering mutliple parameter constraints in one string ', ...
                'separated with semicolon is obsolete, and will be remove ', ...
                'from a future version of Matlab. ', ...
                'Use cell array of strings instead.']);
            % Read individual &-separated restrictions.
            rest = regexp(rest,'(.*?)(?:&|$)','tokens');
            rest = strtrim([rest{:}]);
        else
            rest = {rest};
        end
    end
    % Convert restrictions to implicit forms: `A=B` to `A-B`.
    rest = regexprep(rest,'=(.*)','-\($1\)');
    % Vectorise and vertically concatenate all general restrictions.
    rest = regexprep(rest,'.*','xxVec($0);');
    rest = ['[',rest{:},']'];
end

% A, C, G restrictions.
if ~isempty(rest)
    % General constraints exist. Set up (Q,q) first for general and plain
    % constraints, then convert them to (R,r).
    restFn = eval(['@(c,a,g) ',rest,';']);
    [Q1,q1] = xxGeneralRest(restFn,Ny,Nk,Ng,nLag);
    Q = [Q;Q1];
    q = [q;q1];
    % Plain constraints.
    if isPlain
        [Q2,q2] = xxPlainRest1(Opt,Ny,Nk,Ng,nLag);
        Q = [Q;Q2];
        q = [q;q2];
    end
    % Convert Q*beta + q = 0 to beta = R*gamma + r,
    % where gamma is a vector of free hyperparameters.
    if ~isempty(Q)
        Rr = xxQq2Rr([Q,q]);
    end
    if nargout > 1
        Qq = sparse([Q,q]);
    end
elseif isPlain
    [R,r] = xxPlainRest2(Opt,Ny,Nk,Ng,nLag);
    Rr = sparse([R,r]);
    if nargout > 1
        Qq = xxRr2Qq(Rr);
    end
end

end

% Subfunctions...


%**************************************************************************
function [Q,q] = xxGeneralRest(RestFn,Ny,Nk,Ng,NLag)
% Q*beta = q
aux = reshape(transpose(1:Ny*(Nk+Ny*NLag+Ng)),[Ny,Nk+Ny*NLag+Ng]);
cInx = aux(:,1:Nk);
aux(:,1:Nk) = [];
aInx = reshape(aux(:,1:Ny*NLag),[Ny,Ny,NLag]);
aux(:,1:Ny*NLag) = [];
gInx = aux;
c = zeros(size(cInx)); % Constant.
a = zeros(size(aInx)); % Transition matrix.
g = zeros(size(gInx)); % Cointegrating vector.
% Q*beta + q = 0.
try
    q = RestFn(c,a,g);
catch Error
    utils.error('VAR', ...
        ['Error evaluating parameter restrictions.\n', ...
        '\tMatlab says: %s'], ...
        Error.message);
end
nRest = size(q,1);
Q = zeros(nRest,Ny*(Nk+Ny*NLag+Ng));
for i = 1 : numel(c)
    c(i) = 1;
    Q(:,cInx(i)) = RestFn(c,a,g) - q;
    c(i) = 0;
end
for i = 1 : numel(a)
    a(i) = 1;
    Q(:,aInx(i)) = RestFn(c,a,g) - q;
    a(i) = 0;
end
for i = 1 : numel(g)
    g(i) = 1;
    Q(:,gInx(i)) = RestFn(c,a,g) - q;
    g(i) = 0;
end
end % xxGeneralRest()


%**************************************************************************
function [Q,q] = xxPlainRest1(Opt,Ny,Nk,Ng,NLag)
[A,C,G] = xxAssignPlainRest(Opt,Ny,Nk,Ng,NLag);
nBeta = Ny*(Nk+Ny*NLag+Ng);
% Construct parameter restrictions first,
% Q*beta + q = 0,
% splice them with the general restrictions
% and only then convert these to hyperparameter form.
Q = eye(nBeta);
q = -[C,A(:,:),G];
q = q(:);
inx = ~isnan(q);
Q = Q(inx,:);
q = q(inx);
end % xxPlainRest1()


%**************************************************************************
function [R,r] = xxPlainRest2(Opt,Ny,Nk,Ng,NLag)
[A,C,G] = xxAssignPlainRest(Opt,Ny,Nk,Ng,NLag);
nbeta = Ny*(Nk+Ny*NLag+Ng);
% Construct directly hyperparameter form:
% beta = R*gamma + r.
R = eye(nbeta);
r = [C,A(:,:),G];
r = r(:);
inx = ~isnan(r);
R(:,inx) = [];
r(~inx) = 0;
end % xxPlainRest2()


%**************************************************************************
function [A,C,G] = xxAssignPlainRest(Opt,Ny,Nk,Ng,NLag)
A = nan(Ny,Ny,NLag);
C = nan(Ny,Nk);
G = nan(Ny,Ng);
if ~isempty(Opt.a)
    try
        A(:,:,:) = Opt.a;
    catch
        utils.error('VAR', ...
            ['Error setting up VAR restrictions for matrix A. ',...
            'Size of the matrix must be %s.'], ...
            sprintf('%g-by-%g-by-%g',Ny,Ny,NLag));
    end
end
if ~isempty(Opt.c)
    try
        C(:,:) = Opt.c;
    catch
        utils.error('VAR', ...
            ['Error setting up VAR restrictions for matrix C. ',...
            'Size of the matrix must be %s.'], ...
            sprintf('%g-by-%g',Ny,Nk));
    end
end
if ~isempty(Opt.g)
    try
        G(:,:) = Opt.g;
    catch
        utils.error('VAR', ...
            ['Error setting up VAR restrictions for matrix G. ',...
            'Size of the matrix must be %s.'], ...
            sprintf('%g-by-%g-by-%g',Ny,Ng));
    end
end
end % xxAssignPlainRest()


%**************************************************************************
function X = xxVec(X) %#ok<DEFNU>
X = X(:);
end % xxVec()


%**************************************************************************
function RR = xxQq2Rr(QQ)
% xxRr2Qq  Convert Q-restrictions to R-restrictions.
Q = QQ(:,1:end-1);
q = QQ(:,end);
R = null(Q);
r = -pinv(Q)*q;
RR = sparse([R,r]);
end % xxQq2Rr()


%**************************************************************************
function QQ = xxRr2Qq(RR)
% xxRr2Qq  Convert R-restrictions to Q-restrictions when they are unknown.
R = RR(:,1:end-1);
r = RR(:,end);
Q = null(R.').';
q = -Q*r;
QQ = sparse([Q,q]);
end % xxRr2Qq()
