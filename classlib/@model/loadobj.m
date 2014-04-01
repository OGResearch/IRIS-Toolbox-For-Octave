function This = loadobj(This)
% loadobj  [Not a public function] Prepare model object for use in workspace and handle bkw compatibility.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% If the input object is not a model, rebuild the model to make sure the
% equations derived from the user equations (derivatives, etc) comply with
% the latest version of IRIS.
isRebuild = ~isa(This,'model');

This = modelobj.loadobj(This);

if ~isa(This,'model') && ~isfield(This,'d2s')
    % Convert meta to D2S.
    doD2s();
end

if ~isa(This,'model')
    if isfield(This,'eqtnnonlin')
        This.nonlin = This.eqtnnonlin;
    elseif ~isfield(This,'nonlin')
        This.nonlin = false(size(This.eqtn));
    end
elseif isempty(This.nonlin)
    This.nonline = false(size(This.eqtn));
end

if isstruct(This)
    This = model(This);
end

ny = sum(This.nametype == 1);
[nx,~,nAlt] = size(This.solution{1});

% Convert array of occurences to sparse matrix.
if ~issparse(This.occur)
    This.occur = sparse(This.occur(:,:));
end

% Add empty dtrend equations if missing.
if ny > 0 && sum(This.eqtntype == 3) == 0
    This.eqtn(end+(1:ny)) = {''};
    This.eqtnS(end+(1:ny)) = {''};
    This.eqtnF(end+(1:ny)) = {@(x,t,ttrend)0};
    This.eqtnlabel(end+(1:ny)) = {''};
    This.eqtntype(end+(1:ny)) = 3;
    This.occur(end+(1:ny),:) = false;
end

% Store only non-empty dynamic links.
link = This.eqtn(This.eqtntype == 4);
emptylink = cellfun(@isempty,link);
if any(emptylink)
    occur = This.occur(This.eqtntype == 4,:);
    linkLabel = This.eqtnlabel(This.eqtntype == 4);
    linkF = This.eqtnF(This.eqtntype == 4);
    linkNonlin = This.nonlin(This.eqtntype == 4);
    This.eqtn(This.eqtntype == 4) = [];
    This.eqtnlabel(This.eqtntype == 4) = [];
    This.eqtnF(This.eqtntype == 4) = [];
    This.nonlin(This.eqtntype == 4) = [];
    This.occur(This.eqtntype == 4,:) = [];
    This.eqtntype(This.eqtntype == 4) = [];
    This.eqtn = [This.eqtn,link(This.Refresh)];
    This.eqtnlabel = [This.eqtnlabel,linkLabel(This.Refresh)];
    This.eqtnF = [This.eqtnF,linkF(This.Refresh)];
    This.nonlin = [This.nonlin,linkNonlin(This.Refresh)];
    This.occur = [This.occur;occur(This.Refresh,:)];
    This.eqtntype = [This.eqtntype,4*ones(size(This.Refresh))];
end

% Occurence of names in steady-state equations.
if isempty(This.occurS) && ~This.linear
    This.occurS = any(This.occur,3);
end

% Add flags and deriv0.n for equations earmarked for non-linear
% simulations.
if isempty(This.nonlin)
    This.nonlin = false(size(This.eqtn));
end

% Effect of add-factor on transition equations.
if ~isfield(This.system0,'N') || isempty(This.system0.N)
    This.system0.N = {[],zeros(nx,0)};
end
if ~isfield(This.deriv0,'n') || isempty(This.deriv0.n)
    This.deriv0.n = zeros(ny+nx,0);
end

% Effect of add-factors in solution for non-linear equations.
if length(This.solution) < 8 || isempty(This.solution{8})
    This.solution{8} = nan(nx,0,nAlt);
end

if ~isempty(This.Expand) ...
        && (length(This.Expand) < 6 || isempty(This.Expand{6}))
    % The size of Expand{6} in 1st dimension is the number of fwl variables
    % *before* we remove the double occurences from state space. `Expand{6}`
    % can be empty also in nonlinear bkw models; in that case, we need to set
    % the size in second dimension appropriately.
    nNonlin = sum(This.nonlin);
    This.Expand{6} = nan(size(This.Expand{3},1),nNonlin,nAlt);
end

if ~isempty(This.Assign) && isempty(This.stdcorr)
    % Separate std devs from Assign, and create zero cross corrs.
    doStdcorr();
end

if isempty(This.solutionvector) ...
        || all(cellfun(@isempty,This.solutionvector))
    This.solutionvector = { ...
        myvector(This,'y'), ...
        myvector(This,'x'), ...
        myvector(This,'e'), ...
        };
end

if isempty(This.multiplier)
    This.multiplier = false(size(This.name));
end

% This property is no longer in use.
This.userdifflist = cell(1,0);

if isempty(This.Tolerance) || isnan(This.Tolerance)
    This.Tolerance = getrealsmall();
end

if isempty(This.Autoexogenise)
    This.Autoexogenise = nan(size(This.name));
end

% Replace L(N) with L(:,N) in full equations, `This.eqtnF`.
for i = 1 : length(This.eqtnF)
    eqtn = This.eqtnF{i};
    if isempty(eqtn)
        continue
    end
    isFunc = isa(eqtn,'function_handle');
    if isFunc
        eqtn = func2str(eqtn);
    end
    eqtn = regexprep(eqtn,'L\((\d+)\)','L(:,$1)');
    This.eqtnF{i} = eqtn;
end

% Restore the transient property `eqtnN` , i.e. the function handles for
% evaluating non-linearised equations.
This = mynonlineqtn(This);

% Convert equation strings to anonymous functions.
try
    This = myeqtn2afcn(This);
catch %#ok<CTCH>
    % The function `myeqtn2afcn` may fail because of an old structure of
    % derivatives or missing equations for constant terms in linear models.
    This = mysymbdiff(This);
    This = myeqtn2afcn(This);
end

if isRebuild
    This = model(This);
end

% Nested functions.

%**************************************************************************
    function doStdcorr()
        ne = sum(This.nametype == 3);
        nName = length(This.name);
        stdvec = This.Assign(1,end-ne+1:end,:);
        This.stdcorr = stdvec;
        This.stdcorr(end+(1:ne*(ne-1)/2)) = 0;
        This.Assign(:,end-ne+1:end,:) = [];
        This.Assign0(:,end-ne+1:end,:) = [];
        occur = reshape(full(This.occur), ...
            [size(This.occur,1),nName,size(This.occur,2)/nName]);
        occur(:,end-ne+1:end,:) = [];
        This.occur = sparse(occur(:,:));
        This.occurS = occur(:,end-ne+1:end);
        This.name(:,end-ne+1:end) = [];
        This.nametype(:,end-ne+1:end) = [];
        This.namelabel(:,end-ne+1:end) = [];
        This.log(:,end-ne+1:end) = [];
    end % doStdcorr().

%**************************************************************************
    function doD2s()
        This.d2s = struct();
        % Positions in derivative matrices.
        This.d2s.y_ = This.metaderiv.y;
        This.d2s.xu1_ = This.metaderiv.uplus;
        This.d2s.xu_ = This.metaderiv.u;
        This.d2s.xp1_ = This.metaderiv.pplus;
        This.d2s.xp_ = This.metaderiv.p;
        This.d2s.e_ = This.metaderiv.e;
        % Positions in unsolved system matrices.
        This.d2s.y = This.metasystem.y;
        This.d2s.xu1 = This.metasystem.uplus;
        This.d2s.xu = This.metasystem.u;
        This.d2s.xp1 = This.metasystem.pplus;
        This.d2s.xp = This.metasystem.p;
        This.d2s.e = This.metasystem.e;
        % Dynamic identities.
        This.d2s.ident1 = This.systemident.xplus;
        This.d2s.ident = This.systemident.x;
        % Non-predetermined variables removed from solution.
        This.d2s.remove = This.metadelete;
    end % doD2s().

end