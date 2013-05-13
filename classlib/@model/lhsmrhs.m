function Q = lhsmrhs(This,varargin)
% lhsmrhs  Evaluate the discrepancy between the LHS and RHS for each model equation and given data.
%
% Syntax for casual evaluation
% =============================
%
%     Q = lhsmrhs(M,D,Range)
%
% Syntax for fast evaluation
% ===========================
%
%     Q = lhsmrhs(M,YXE)
%
% Input arguments
% ================
%
% `M` [ model ] - Model object whose equations and currently assigned
% parameters will be evaluated.
%
% `YXE` [ numeric ] - Numeric array created from an input database by
% calling the function [`data4lhsmrhs`](model/data4lhsmrhs); `YXE` contains
% the observations on the measurement variables, transition variables, and
% shocks organised row-wise.
%
% * `D` [ struct ] - Input database with observations on measurement
% variables, transition variables, and shocks on which the discrepancies
% will be evaluated.
%
% * `Range` [ numeric ] - Date range on which the discrepancies will be
% evaluated.
%
% Output arguments
% =================
%
% `Q` [ numeric ] - Numeric array with discrepancies between the LHS and
% RHS for each model equation.
%
% Description
% ============
%
% The function `lhsmrhs` evaluates the discrepancy between the LHS and the
% RHS in each model equation; each lead is replaced with the actual
% observation supplied in the input data. The function `lhsmrhs` does not
% work for models with [references to steady state
% values](modellang/sstateref).
%
% The first syntax, with the array `YXE` pre-built in a call to
% [`data4lhsmrhs`](model/data4lhsmrhs) is computationally much more
% efficient if you need to evaluate the LHS-RHS discrepancies repeatedly
% for different parameterisations.
%
% The output argument `D` is an `nEqtn` by `nPer` by `nAlt` array, where
% `nEqnt` is the number of measurement and transition equations, `nPer` is
% the number of periods used to create `X` in a prior call to
% [`data4lhsmrhs`](model/data4lhsmrhs), and `nAlt` is the greater of the
% number of alternative parameterisations in `M`, and the number of
% alternative datasets in the input data.
%
% Example
% ========
%
%     YXE = data4lhsmrhs(M,d,range);
%     Q = lhsmrhs(M,YXE);
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if isnumeric(varargin{1})
    % Fast syntax.
    YXE = varargin{1};
    varargin(1) = [];
    L = [];
    if ~isempty(varargin)
        % The vector of steady-state references `L` is passed in only when called
        % from `chksstate()`.
        L = varargin{1};
        varargin(1) = []; %#ok<NASGU>
    end
elseif isstruct(varargin{1})
    % Casual syntax.
    D = varargin{1};
    varargin(1) = [];
    Range = varargin{1};
    varargin{1} = []; %#ok<NASGU>
    YXE = data4lhsmrhs(This,D,Range);
    L = [];
end

%--------------------------------------------------------------------------

% TODO: Deterministic trends.

nXPer = size(YXE,2);
nT = size(This.occur,2) / length(This.name);
preSample = This.tzero - 1;
postSample = nT - This.tzero;
t = preSample+1 : nXPer-postSample;

% Add parameters to the bottom of the `X` array.
nData = size(YXE,3);
nAlt = size(This.Assign,3);
P = This.Assign(1,This.nametype == 4,:);
P = permute(P,[2,1,3]);
P = P(:,ones(1,nXPer),:);
if nData > nAlt && nAlt == 1
    P = P(:,:,ones(1,nData));
elseif nAlt > nData && nData == 1
    YXE = YXE(:,:,ones(1,nAlt));
elseif nAlt ~= nData
    utils.error('model', ...
        ['The number of parameterisations (%g) is not consistent ', ...
        'with the number of data sets (%g).'], ...
        nAlt,nData);
end
YXE = [YXE;P];

% Permute `YXE` and `L` from nName-nPer-nAlt to nAlt-nName-nPer.
YXE = permute(YXE,[3,1,2]);
L = permute(L,[3,1,2]);

% `Q` is created as nAlt-nEqtn-nPer.
eqtnXY = This.eqtnF(This.eqtntype <= 2);
Q = [];
for iAlt = 1 : nAlt
    % `q` is returned as 1-nEqtn-nPer.
    q = cellfun(@(f) f(YXE(iAlt,:,:),t,L(iAlt,:,:)), ...
        eqtnXY,'uniformOutput',false);
    q = [q{:}];
    Q = [Q;q]; %#ok<AGROW>
end

% Permute `D` back to nEqtn-nPer-nAlt.
Q = ipermute(Q,[3,1,2]);

end