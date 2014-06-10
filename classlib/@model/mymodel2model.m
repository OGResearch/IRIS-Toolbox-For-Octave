function This = mymodel2model(This,Asgn,Opt)
% mymodel2model  [Not a public function] Rebuild model object properties.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

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
This.BaseYear = Opt.baseyear;

% Create model-specific meta data.
if any(This.nonlin)
    % Do not remove leads from state space vector if there are
    % non-linearised equations.
    % TODO: More sophisticated check which leads are actually needed in
    % non-linerised equations.
    Opt.removeleads = false;
end
This = myd2s(This,Opt);

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
if ~isempty(Asgn) ...
        && isstruct(Asgn) ...
        && ~isempty(fieldnames(Asgn))
    % Check number of alt params in input database. Exclude shocks.
    list = This.name(This.nametype ~= 3);
    maxlength = 1;
    for i = 1 : length(list)
        if isfield(Asgn,list{i}) && isnumeric(Asgn.(list{i}))
            Asgn.(list{i}) = transpose(Asgn.(list{i})(:));
            maxlength = max(maxlength,length(Asgn.(list{i})));
        end
    end
    % Expand number of alt params if necessary.
    if maxlength > 1
        This = alter(This,maxlength);
    end
    This = assign(This,Asgn);
end

% Pre-compute symbolic derivatives of
% * transition and measurement equations wrt variables,
% * dtrends equations wrt parameters (always).
This = mysymbdiff(This,Opt.symbdiff);

% Convert model equations to anonymous functions.
This = myeqtn2afcn(This);

% Refresh dynamic links.
if ~isempty(This.Refresh) % && any(~isnan(m.Assign(:)))
    This = refresh(This);
end

% Recreate transient properties.
This = mytransient(This);

% Run Blazer.
if Opt.blazer
    [This.NameBlk,This.EqtnBlk] = blazer(This);
end


% Nested functions...


%**************************************************************************


    function doPrealloc()

        ny = sum(This.nametype == 1);
        nx = length(This.systemid{2});
        nb = sum(imag(This.systemid{2}) < 0);
        nf = nx - nb;
        ne = sum(This.nametype == 3);
        nFKeep = sum(~This.d2s.remove);
        nn = sum(This.nonlin);
        nName = length(This.name);

        This.Assign = nan(1,nName);
        % Steady state of shocks fixed to zero, cannot be changed.
        This.Assign(This.nametype == 3) = 0;
        % Steady state of exogenous variables preset to zero, but can be changed.
        This.Assign(This.nametype == 5) = 0;
        This.stdcorr = zeros(1,ne+ne*(ne-1)/2);
        This.stdcorr(1,1:ne) = defaultStd;
        
        This.solution{1} = nan(nFKeep+nb,nb); % T
        This.solution{2} = nan(nFKeep+nb,ne); % R
        This.solution{3} = nan(nFKeep+nb,1); % K
        This.solution{4} = nan(ny,nb); % Z
        This.solution{5} = nan(ny,ne); % H
        This.solution{6} = nan(ny,1); % D
        This.solution{7} = nan(nb,nb); % U
        This.solution{8} = nan(nFKeep+nb,nn); % Y - non-lin addfactors.
        This.solution{9} = nan(ny,nb); % Zb - Untransformed measurement.
        
        This.Expand{1} = nan(nb,nf); % Xa
        This.Expand{2} = nan(nFKeep,nf); % Xf
        This.Expand{3} = nan(nf,ne); % Ru
        This.Expand{4} = nan(nf,nf); % J
        This.Expand{5} = nan(nf,nf); % J^k
        This.Expand{6} = nan(nf,nn); % Mu -- non-lin addfactors.
        
        This.eigval = nan(1,nx);
        This.icondix = false(1,nb);
        
    end % doPrealloc()


end