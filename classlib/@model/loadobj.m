function This = loadobj(This,varargin)
% loadobj  [Not a public function] Prepare model object for use in workspace and handle bkw compatibility.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

This = modelobj.loadobj(This);

if ~isa(This,'model')
    if isfield(This,'eqtnnonlin')
        This.nonlin = This.eqtnnonlin;
    elseif ~isfield(This,'nonlin')
        This.nonlin = false(size(This.eqtn));
    end
elseif isempty(This.nonlin)
    This.nonlin = false(size(This.eqtn));
end

if isfield(This,'torigin')
    This.BaseYear = This.torigin;
end

if isstruct(This)
    This = model(This);
end

solutionid = This.solutionid;
if isempty(This.d2s)
    opt = struct();
    opt.addlead = false;
    opt.removeleads = all(imag(This.solutionid{2}) <= 0);
    This = myd2s(This,opt);
end
if ~isequal(solutionid,This.solutionid)
    disp('Model object failed to be loaded from a disk file.');
    disp('Create the model object again from the model file.');
    This = model();
    return
end

ny = sum(This.nametype == 1);
nAlt = size(This.Assign,3);

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
isEmptyLink = cellfun(@isempty,link);
if any(isEmptyLink)
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
    eqtn = regexprep(eqtn,'\<L\((\d+)\)','L(:,$1)');
    This.eqtnF{i} = eqtn;
end

% Convert equation strings to anonymous functions.
try
    This = myeqtn2afcn(This);
catch %#ok<CTCH>
    % The function `myeqtn2afcn` may fail because of an old structure of
    % derivatives or missing equations for constant terms in linear models.
    isSymbDiff = true;
    This = mysymbdiff(This,isSymbDiff);
    This = myeqtn2afcn(This);
end

% Transient properties
%----------------------
% Reset last system, and create function handles to nonlinear equations.
This = mytransient(This);


% Nested functions...


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
    end % doStdcorr()


end