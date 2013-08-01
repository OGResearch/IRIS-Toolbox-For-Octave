function S = myprepsimulate(This,S,IAlt)
% myprepsimulate  [Not a public function] Prepare the i-th simulation round.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% The input struct `S` must include the followin fields:
%
% * `.isnonlin` - true if a non-linear simulate is requested;
% * `.tplusk` - farthest expansion needed;
%
% The output struct `S` returns the following new fields:
%
% * `.Assign` - current values of parameters and steady states;
% * `.T`...`.U` - solution matrices;
% * `.Expand` - expansion matrices;
% * `.Y` - effect of non-linear add-factors (empty for linear simulations);
%
% For non-linear simulations, the struct `S` is also added the following
% loop-indpendent fields from the model object
%
% * `nonlin` - index of non-linearised equations;
% * `eqtnN` - cell array of function handles to evaluate non-linear
% equations;
% * `eqtn` - cell str of user equations;
% * `nametype` - name types;
% * `label` - equation labels or trimmed equations.

%--------------------------------------------------------------------------

ne = sum(This.nametype == 3);
nn = sum(This.nonlin);

% Loop-dependet fields
%----------------------

% Current values of parameters and steady states.
S.Assign = This.Assign(1,:,IAlt);

% Solution matrices.
S.T = This.solution{1}(:,:,IAlt);
S.R = This.solution{2}(:,:,IAlt);
S.K = This.solution{3}(:,:,IAlt);
S.Z = This.solution{4}(:,:,IAlt);
S.H = This.solution{5}(:,:,IAlt);
S.D = This.solution{6}(:,:,IAlt);
S.U = This.solution{7}(:,:,IAlt);

% Effect of non-linear add-factors.
S.Y = []; 
if S.isNonlin
    S.Y = This.solution{8}(:,:,IAlt);
end

% Solution expansion matrices.
S.Expand = cell(size(This.Expand));
for ii = 1 : numel(S.Expand)
    S.Expand{ii} = This.Expand{ii}(:,:,IAlt);
end

% Expand solution forward up to t+k if needed.
if S.tplusk > 0
    % TODO: Can we only expand non-lin add-factors if there is no need to
    % expand shocks?
    if S.isNonlin && (ne > 0 || nn > 0)
        % Expand solution forward to t+k for both shocks and non-linear
        % add-factors.
        [S.R,S.Y] = model.myexpand(S.R,S.Y,S.tplusk,S.Expand{1:6});
    elseif ne > 0
        % Expand solution forward to t+k for shocks only.
        S.R = model.myexpand(S.R,[],S.tplusk,S.Expand{1:5},[]);
    end
end

if ~S.isNonlin
    return
end

% Loop-independent fields added for non-linear simulations only
%---------------------------------------------------------------
S.nonlin = This.nonlin;
S.eqtn = This.eqtn;
S.eqtnN = This.eqtnN;
S.nametype = This.nametype;
S.label = myget(This,'canBeNonlinearised');

end