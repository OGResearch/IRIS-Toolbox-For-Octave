function This = loadobj(This,varargin)
% loadobj  [Not a public function] Prepare model object for use in workspace and handle bkw compatibility.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

isNotField = @(Obj,Field) isstruct(Obj) && ~isfield(Obj,Field);

This = modelobj.loadobj(This);

if isfield(This,'tzero')
    t0 = This.tzero;
    nt = size(This.occur,2) / length(This.name);
    minT = 1 - t0;
    maxT = nt - t0;
    This.Shift = minT : maxT;
end

if isfield(This,'eqtnnonlin')
    This.IxNonlin = This.eqtnnonlin;
elseif isfield(This,'nonlin')
    This.IxNonlin = This.nonlin;
end

if isNotField(This,'IxNonlin') || isempty(This.IxNonlin)
    This.IxNonlin = false(size(This.eqtn));
end

if isfield(This,'torigin')
    This.BaseYear = This.torigin;
end

if isNotField(This,'BaseYear') || isempty(This.BaseYear)
    This.BaseYear = @config;
end


% Model object
%--------------
if isstruct(This)
    This = model(This);
end


build = sscanf(This.Build,'%g',1);
ny = sum(This.nametype == 1);
ne = sum(This.nametype == 3);
nAlt = size(This.Assign,3);

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

% Convert array of occurences to sparse matrix.
if ~issparse(This.occur)
    This.occur = sparse(This.occur(:,:));
end

% Add empty dtrend equations if missing.
if ny > 0 && sum(This.eqtntype == 3) == 0
    This.eqtn(end+(1:ny)) = {''};
    This.EqtnS(end+(1:ny)) = {''};
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
    linkNonlin = This.IxNonlin(This.eqtntype == 4);
    This.eqtn(This.eqtntype == 4) = [];
    This.eqtnlabel(This.eqtntype == 4) = [];
    This.eqtnF(This.eqtntype == 4) = [];
    This.IxNonlin(This.eqtntype == 4) = [];
    This.occur(This.eqtntype == 4,:) = [];
    This.eqtntype(This.eqtntype == 4) = [];
    This.eqtn = [This.eqtn,link(This.Refresh)];
    This.eqtnlabel = [This.eqtnlabel,linkLabel(This.Refresh)];
    This.eqtnF = [This.eqtnF,linkF(This.Refresh)];
    This.IxNonlin = [This.IxNonlin,linkNonlin(This.Refresh)];
    This.occur = [This.occur;occur(This.Refresh,:)];
    This.eqtntype = [This.eqtntype,4*ones(size(This.Refresh))];
end

% Occurence of names in steady-state equations.
if isempty(This.occurS) && ~This.IsLinear
    This.occurS = any(This.occur,3);
end

if ~isempty(This.Expand) ...
        && (length(This.Expand) < 6 || isempty(This.Expand{6}))
    % The size of Expand{6} in 1st dimension is the number of fwl variables
    % *before* we remove the double occurences from state space. `Expand{6}`
    % can be empty also in nonlinear bkw models; in that case, we need to set
    % the size in second dimension appropriately.
    nNonlin = sum(This.IxNonlin);
    This.Expand{6} = nan(size(This.Expand{3},1),nNonlin,nAlt);
end

if ~isempty(This.Assign) && ne > 0 && isempty(This.stdcorr)
    % Separate std devs from Assign, and create zero cross corrs.
    doStdcorr();
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

% Replace `L(N)` and `L(:,N)` with `L(:,N,t)` in full equations.
for i = 1 : length(This.eqtnF)
    eqtn = This.eqtnF{i};
    if isempty(eqtn)
        continue
    end
    isFunc = isa(eqtn,'function_handle');
    if isFunc
        eqtn = func2str(eqtn);
    end
    eqtn = regexprep(eqtn,'\<L\((\d+)\)','L(:,$1,t)');
    eqtn = regexprep(eqtn,'\<L\(:,(\d+)\)','L(:,$1,t)');
    This.eqtnF{i} = eqtn;
end

% Rewrite log-variables in sstate equations for builds < 20140611.
if build < 20140610 && ~This.IsLinear
    doLogSstateEqtn();
end

% Remove multiplication by x from derivatives wrt to log variables.
if build < 20140620
    doLogDeqtnF();
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
        This.IxLog(:,end-ne+1:end) = [];
    end % doStdcorr()


%**************************************************************************


    function doLogSstateEqtn()
        % For each log variable:
        % * replace `exp(x(10)-2*dx(10))` with `(x(10)/dx(10)^2)`;
        % * replace `exp(x(10)+2*dx(10))` with `(x(10)*dx(10)^2)`;
        % * replace `exp(x(10))` with `x(10)`;
        % * replace `((x(10)))` with `(x(10))`.
        for ii = find(This.IxLog)
            iic = sprintf('%g',ii);
            This.EqtnS = regexprep(This.EqtnS, ...
                ['exp\(x\(',iic,'\)\-(\d+)\*dx\(',iic,'\)\)'], ...
                ['\(x\(',iic,'\)/dx\(',iic,'\)^$1\)']);
            This.EqtnS = regexprep(This.EqtnS, ...
                ['exp\(x\(',iic,'\)\+(\d+)\*dx\(',iic,'\)\)'], ...
                ['\(x\(',iic,'\)*dx\(',iic,'\)^$1\)']);
            This.EqtnS = regexprep(This.EqtnS, ...
                ['exp\(x\(',iic,'\)\)'], ...
                ['x\(',iic,'\)']);
        end
        This.EqtnS = regexprep(This.EqtnS, ...
            '\(\(x\((\d+)\)\)\)', ...
            '(x($1))');
    end % doLogSstateEqtn()


%**************************************************************************


    function doLogDeqtnF()
        % Remove `.*[...]` from the end of each transition and measurement
        % equation.
        for ii = find(This.eqtntype <= 2)
            eqtn = This.DEqtnF{ii};
            if isfunc(eqtn)
                eqtn = func2str(eqtn);
            end
            if isempty(eqtn)
                continue
            end
            eqtn = regexprep(eqtn,'\.\*\[[^\[]+\]$','');
            This.DEqtnF{ii} = str2func(eqtn);
        end
    end % doLogDeqtnF()


end
