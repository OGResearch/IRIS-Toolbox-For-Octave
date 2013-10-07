function This = mymodel2model(This,Assign,Opt)
% mymodel2model  [Not a public function] Rebuild model object properties.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Assign user comment if it is non-empty, otherwise use what has been
% found in the model code.
if ~isempty(Opt.comment)
    This.Comment = Opt.comment;
end

% Differentiation step size.
if ~isempty(Opt.epsilon)
    This.epsilon = Opt.epsilon;
end

% Time origin (base year) for deterministic trends.
if ~isempty(Opt.torigin) && isintscalar(Opt.torigin)
    This.torigin = Opt.torigin;
end

% Create model-specific meta data.
if any(This.nonlin)
    % Do not remove leads from state space vector if there are
    % non-linearised equations.
    % TODO: More sophisticated check which leads are actually needed in
    % non-linerised equations.
    Opt.removeleads = false;
end
This = myd2s(This,Opt);

% Create equations for evaluating the LHS minus RHS; these can be created
% only after we know the solution ids.
This = mynonlineqtn(This);

% Assign default stddevs.
if ~isnan(Opt.std) && ~isempty(Opt.std)
    defaultStd = Opt.std;
elseif This.linear
    defaultStd = 1;
else
    defaultStd = log(1.01);
end

% Pre-allocate solution matrices etc. Also assign zero steady states to
% shocks and default stdevs.
doPrealloc();
if ~isempty(Assign) ...
        && isstruct(Assign) ...
        && ~isempty(fieldnames(Assign))
    % Check number of alt params in input database. Exclude shocks.
    list = This.name(This.nametype ~= 3);
    maxlength = 1;
    for i = 1 : length(list)
        if isfield(Assign,list{i}) && isnumeric(Assign.(list{i}))
            Assign.(list{i}) = transpose(Assign.(list{i})(:));
            maxlength = max(maxlength,length(Assign.(list{i})));
        end
    end
    % Expand number of alt params if necessary.
    if maxlength > 1
        This = alter(This,maxlength);
    end
    This = assign(This,Assign);
end

% Pre-compute symbolic derivatives of
% * transition and measurement equations wrt variables,
% * dtrends equations wrt parameters (always).
This = mysymbdiff(This);

% Convert model equations to anonymous functions.
This = myeqtn2afcn(This);

% Refresh dynamic links.
if ~isempty(This.Refresh) % && any(~isnan(m.Assign(:)))
    This = refresh(This);
end

% Nested functions.

%**************************************************************************
    function doPrealloc()
        if issparse(This.occur)
            nt = size(This.occur,2)/length(This.name);
        else
            nt = size(This.occur,3);
        end
        
        nDeriv = nt*sum(This.nametype <= 3);
        n = sum(This.eqtntype <= 2);
        This.deriv0.c = zeros(n,1);
        This.deriv0.f = sparse(zeros(n,nDeriv));
        tempEye = -eye(n);
        This.deriv0.n = tempEye(:,This.nonlin);
        
        % Sizes of system matrices (different from solution matrices).
        ny = sum(This.nametype == 1);
        nx = length(This.systemid{2});
        ne = sum(This.nametype == 3);
        nf = sum(imag(This.systemid{2}) >= 0);
        nb = nx - nf;
        This.system0.K{1} = zeros(ny,1);
        This.system0.K{2} = zeros(nx,1);
        This.system0.A{1} = sparse(zeros(ny,ny));
        This.system0.B{1} = sparse(zeros(ny,nb));
        This.system0.E{1} = sparse(zeros(ny,ne));
        This.system0.N{1} = [];
        This.system0.A{2} = sparse(zeros(nx,nx));
        This.system0.B{2} = sparse(zeros(nx,nx));
        This.system0.E{2} = sparse(zeros(nx,ne));
        This.system0.N{2} = zeros(nx,sum(This.nonlin));
        
        This.Assign = nan(1,length(This.name));
        % Steady state of shocks fixed to zero, cannot be changed.
        This.Assign(This.nametype == 3) = 0;
        % Steady state of exogenous variables preset to zero, but can be changed.
        This.Assign(This.nametype == 5) = 0;
        This.Assign0 = This.Assign;
        This.stdcorr = zeros(1,ne+ne*(ne-1)/2);
        This.stdcorr(1,1:ne) = defaultStd;
        
        ny = sum(This.nametype == 1);
        nx = length(This.systemid{2});
        nb = sum(imag(This.systemid{2}) < 0);
        nf = nx - nb;
        ne = sum(This.nametype == 3);
        nFKeep = sum(~This.d2s.remove);
        nn = sum(This.nonlin);
        
        This.solution{1} = nan(nFKeep+nb,nb); % T
        This.solution{2} = nan(nFKeep+nb,ne); % R
        This.solution{3} = nan(nFKeep+nb,1); % K
        This.solution{4} = nan(ny,nb); % Z
        This.solution{5} = nan(ny,ne); % H
        This.solution{6} = nan(ny,1); % D
        This.solution{7} = nan(nb,nb); % U
        This.solution{8} = nan(nFKeep+nb,nn); % M -- non-lin addfactors.
        
        This.Expand{1} = nan(nb,nf); % Xa
        This.Expand{2} = nan(nFKeep,nf); % Xf
        This.Expand{3} = nan(nf,ne); % Ru
        This.Expand{4} = nan(nf,nf); % J
        This.Expand{5} = nan(nf,nf); % J^k
        This.Expand{6} = nan(nf,nn); % Mu -- non-lin addfactors.
        
        This.eigval = nan(1,nx);
        This.icondix = false(1,nb);
    end % doPrealloc().

end