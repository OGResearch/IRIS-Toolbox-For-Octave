function [Rr,Qq] = restrict(NY,NK,NG,Opt)
% restrict  [Not a public function] Convert parameter restrictions to hyperparameter matrix form.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

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

nBeta = NY*(NK+NY*nLag+NG);
Q = zeros(0,nBeta);
q = zeros(0);

isPlain = ~isempty(Opt.a) ...
    || ~isempty(Opt.c) ...
    || ~isempty(Opt.g);

% General constraints.
rString = '';
restrict = lower(strtrim(Opt.constraints));
if ~isempty(restrict)
    restrict = strfun.converteols(restrict);
    restrict = strrep(restrict,char(10),' ');
    restrict = lower(restrict);
    % Replace semicolons outside brackets with &s.
    restrict = strfun.strrepoutside(restrict,';','&','[]','()');
    % Read individual &-separated restrictions.
    eachRestrict = regexp(restrict,'(.*?)(?:&|$)','tokens');
    % Convert restrictions to implicit forms.
    eachRestrict = regexprep([eachRestrict{:}],...
        '=(.*)','-\($1\)');
    % Vectorise and vertically concatenate restrictions.
    for i = 1 : numel(eachRestrict)
        rString = [rString,'xxVec(',eachRestrict{i},');']; %#ok<AGROW>
    end
    if ~isempty(rString)
        rString = ['[',rString,']'];
    end
end

% A, C, G restrictions.
if ~isempty(rString)
    % General constraints exist. Set up (Q,q) first for general and plain
    % constraints, then convert them to (R,r).
    rfunc = eval(['@(c,a,g) ',rString,';']);
    [Q1,q1] = xxGeneralRestrict(rfunc,NY,NK,NG,nLag);
    Q = [Q;Q1];
    q = [q;q1];
    % Plain constraints.
    if isPlain
        [Q2,q2] = xxPlainRestrict1(Opt,NY,NK,NG,nLag);
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
    [R,r] = xxPlainRestrict2(Opt,NY,NK,NG,nLag);
    Rr = sparse([R,r]);
    if nargout > 1
        Qq = xxRr2Qq(Rr);
    end
end

end

% Subfunctions.

%**************************************************************************
function [Q,q] = xxGeneralRestrict(RFunc,NY,NK,NG,NLag)
% Q*beta = q
aux = reshape(transpose(1:NY*(NK+NY*NLag+NG)),[NY,NK+NY*NLag+NG]);
cInx = aux(:,1:NK);
aux(:,1:NK) = [];
aInx = reshape(aux(:,1:NY*NLag),[NY,NY,NLag]);
aux(:,1:NY*NLag) = [];
gInx = aux;
c = zeros(size(cInx)); % Constant.
a = zeros(size(aInx)); % Transition matrix.
g = zeros(size(gInx)); % Cointegrating vector.
% Q*beta + q = 0.
try
    q = RFunc(c,a,g);
catch Error
    utils.error('VAR', ...
        ['Error evaluating parameter restrictions.\n', ...
        '\tMatlab says: %s'], ...
        Error.message);
end
nRestrict = size(q,1);
Q = zeros([nRestrict,NY*(NK+NY*NLag+NG)]);
for i = 1 : numel(c)
    c(i) = 1;
    Q(:,cInx(i)) = RFunc(c,a,g) - q;
    c(i) = 0;
end
for i = 1 : numel(a)
    a(i) = 1;
    Q(:,aInx(i)) = RFunc(c,a,g) - q;
    a(i) = 0;
end
for i = 1 : numel(g)
    g(i) = 1;
    Q(:,gInx(i)) = RFunc(c,a,g) - q;
    g(i) = 0;
end
end % xxGeneralRestrict().

%**************************************************************************
function [Q,q] = xxPlainRestrict1(Opt,NY,NK,NG,NLag)
[A,C,G] = xxAssignPlainRestrict(Opt,NY,NK,NG,NLag);
nBeta = NY*(NK+NY*NLag+NG);
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
end % xxPlainRestrict1().

%**************************************************************************
function [R,r] = xxPlainRestrict2(Opt,NY,NK,NG,NLag)
[A,C,G] = xxAssignPlainRestrict(Opt,NY,NK,NG,NLag);
nbeta = NY*(NK+NY*NLag+NG);
% Construct directly hyperparameter form:
% beta = R*gamma + r.
R = eye(nbeta);
r = [C,A(:,:),G];
r = r(:);
inx = ~isnan(r);
R(:,inx) = [];
r(~inx) = 0;
end % xxplainrestrict2().

%********************************************************************
function [A,C,G] = xxAssignPlainRestrict(Opt,NY,NK,NG,NLag)
A = nan(NY,NY,NLag);
C = nan(NY,NK);
G = nan(NY,NG);
if ~isempty(Opt.a)
    try
        A(:,:,:) = Opt.a;
    catch
        utils.error('VAR', ...
            ['Error setting up VAR restrictions for matrix A. ',...
            'Size of the matrix must be %s.'], ...
            sprintf('%g-by-%g-by-%g',NY,NY,NLag));
    end
end
if ~isempty(Opt.c)
    try
        C(:,:) = Opt.c;
    catch
        utils.error('VAR', ...
            ['Error setting up VAR restrictions for matrix C. ',...
            'Size of the matrix must be %s.'], ...
            sprintf('%g-by-%g',NY,NK));
    end
end
if ~isempty(Opt.g)
    try
        G(:,:) = Opt.g;
    catch
        utils.error('VAR', ...
            ['Error setting up VAR restrictions for matrix G. ',...
            'Size of the matrix must be %s.'], ...
            sprintf('%g-by-%g-by-%g',NY,NG));
    end
end
end % xxAssignPlainRestrict().

%**************************************************************************
function x = xxVec(x) %#ok<DEFNU>
x = x(:);
end % xxVec().

%**************************************************************************
function RR = xxQq2Rr(QQ)
% xxRr2Qq  Convert Q-restrictions to R-restrictions.
Q = QQ(:,1:end-1);
q = QQ(:,end);
R = null(Q);
r = -pinv(Q)*q;
RR = sparse([R,r]);
end % xxQq2Rr().

%**************************************************************************
function QQ = xxRr2Qq(RR)
% xxRr2Qq  Convert R-restrictions to Q-restrictions when they are unknown.
R = RR(:,1:end-1);
r = RR(:,end);
Q = null(R.').';
q = -Q*r;
QQ = sparse([Q,q]);
end % xxRr2Qq().
