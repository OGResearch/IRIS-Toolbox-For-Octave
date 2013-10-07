function V = VAR(This,Select,Range,varargin)
% VAR  Population VAR for selected model variables.
%
% Syntax
% =======
%
%     V = VAR(M,Select,Range,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Solved model object.
%
% * `Select` [ cellstr | char ] - List of variables selected for the VAR.
%
% * `Range` [ numeric ] - Hypothetical range, including pre-sample initial
% condition, on which the VAR would be estimated.
%
% Output arguments
% =================
%
% * `V` [ VAR ] - Asymptotic reduced-form VAR for selected model variables.
%
% Options
% ========
%
% * `'order='` [ numeric | *1* ] - Order of the VAR.
%
% * `'constant='` [ *`true`* | `false` ] - Include in the VAR a constant vector
% derived from the steady state of the selected variables.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Parse required arguments.
pp = inputParser();
pp.addRequired('m',@ismodel);
pp.addRequired('list',@(x) ischar(x) || iscellstr(x));
pp.addRequired('range',@isnumeric);
pp.parse(This,Select,Range);

% Parse options.
opt = passvalopt('model.VAR',varargin{:});

% Convert char list to cellstr.
if ischar(Select)
    Select = regexp(Select, ...
        '[a-zA-Z][\w\(\)\{\}\+\-]*','match');
end

%--------------------------------------------------------------------------

nAlt = size(This.Assign,3);
nz = length(Select);
p = opt.order;
C = acf(This,opt.acf{:},'order=',p,'output=','numeric');
Range = Range(1) : Range(end);
nPer = length(Range);
nk = double(opt.constant);

% Find the position of selected variables in the sspace vector and in the
% model names.
[sspacePos,namePos] = myfindsspacepos(This,Select,'-error');

C = C(sspacePos,sspacePos,:,:);
zBar = permute(This.Assign(1,namePos,:),[2,3,1]);
isLog = This.log(1,namePos);
zBar(isLog) = log(zBar(isLog));

% TODO: Calculate Sigma.
V = VAR();
V.A = nan(nz,nz*p,nAlt);
V.K = zeros(nz,nAlt);
V.Omega = nan(nz,nz,nAlt);
V.Sigma = [];
V.G = nan(nz,0,nAlt);
V.range = Range;
V.fitted = true(1,nPer);
V.fitted(1:p) = false;
V.nhyper = nz*(nk+p*nz);

for iAlt = 1 : nAlt
    Ci = C(:,:,:,iAlt);
    zbari = zBar(:,iAlt);
    
    % Put together moment matrices.
    % M1 := [C1, C2, ...]
    M1 = reshape(Ci(:,:,2:end),nz,nz*p);
    
    % M0 := [C0, C1, ...; C1', C0, ... ]
    % First, produce M0' : = [C0, C1', ...; C1, C0, ...].
    M0t = [];
    for i = 0 : p-1
        M0t = [M0t; ...
            nan(nz,nz*i),reshape(Ci(:,:,1:p-i),nz,nz*(p-i)) ...
            ]; %#ok<AGROW>
    end
    M0 = M0t.';
    nanInx = isnan(M0t);
    M0t(nanInx) = M0(nanInx); %#ok<AGROW>
    % Then, tranpose M0' to get M0.
    M0 = M0t.';
    
    % Compute transition matrix.
    Ai = M1 / M0;
    
    % Estimate cov matrix of residuals.
    Omgi = Ci(:,:,1) - M1*Ai.' - Ai*M1.' + Ai*M0*Ai.';
    
    % Calculate constant vector.
    Ki = zeros(size(zbari));
    if opt.constant
        Ki = sum(poly.var2poly(Ai),3)*zbari;
    end
    
    % Populate VAR properties.
    V.A(:,:,iAlt) = Ai;
    V.K(:,iAlt) = Ki;
    V.Omega(:,:,iAlt) = Omgi;
end

% Assign variable names.
V = myynames(V,Select);

% Create residual names automatically.
V = myenames(V,[]);

% Compute triangular representation.
V = schur(V);

% Populate AIC and SBC criteria.
V = infocrit(V);

end