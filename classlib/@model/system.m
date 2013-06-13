function [A,B,C,D,F,G,H,J,List,NF,Deriv] = system(This,Alt,varargin)
% system  System matrices before model is solved.
%
% Syntax
% =======
%
%     [A,B,C,D,F,G,H,J,List,NF] = system(M)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose system matrices will be returned.
%
% Output arguments
% =================
%
% * `A` [ numeric ] - Matrix at the vector of expectations in the
% transition equation.
%
% * `B` [ numeric ] - Matrix at current vector in the transition equations.
%
% * `C` [ numeric ] - Constant vector in the transition equations.
%
% * `D` [ numeric ] - Matrix at transition shocks in the transition
% equations.
%
% * `F` [ numeric ] - Matrix at measurement variables in the measurement
% equations.
%
% * `G` [ numeric ] - Matrix at predetermined transition variables in the
% measurement variables.
%
% * `H` [ numeric ] - Constant vector in the measurement equations.
%
% * `J` [ numeric ] - Matrix at measurement shocks in the measurement
% equations.
%
% * `List` [ cell ] - Lists of measurement variables, transition variables
% includint their auxiliary lags and leads, and shocks as they appear in
% the rows and columns of the system matrices.
%
% * `NF` [ numeric ] - Number of non-predetermined (forward-looking)
% transition variables.
%
% Options
% ========
%
% * `'linear='` [ *`'auto'`* | `true` | `false` ] - Compute the model using
% a linear approach, i.e. differentiating around zero and not the currently
% assigned steady state.
%
% * `'select='` [ *`true`* | `false` ] - Automatically detect which
% equations need to be re-differentiated based on parameter changes from
% the last time the system matrices were calculated.
%
% Description
% ============
%
% The system before the model is solved has the following form:
%
%     A E[xf;xb] + B [xf(-1);xb(-1)] + C + D e = 0
%
%     F y + G xb + H + J e = 0
%
% where `E` is a conditional expectations operator, `xf` is a vector of
% non-predetermined (forward-looking) transition variables, `xb` is a
% vector of predetermined (backward-looking) transition variables, `y` is a
% vector of measurement variables, and `e` is a vector of transition and
% measurement shocks.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

opt = passvalopt('model.system',varargin{:});

if ischar(opt.linear) && strcmpi(opt.linear,'auto')
    opt.linear = This.linear;
end

%--------------------------------------------------------------------------

if nargin < 2
    nAlt = size(This.Assign,3);
    Alt = 1 : nAlt;
elseif islogical(Alt)
    Alt = find(Alt);
end

% System matrices.
for iAlt = transpose(Alt(:))
    eqSelect = myaffectedeqtn(This,iAlt,opt.select,opt.linear);
    eqSelect(This.eqtntype >= 3) = false;
    [This,Deriv] = myderiv(This,eqSelect,iAlt,opt.symbolic,opt.linear);
    [This,sys] = mysystem(This,Deriv,eqSelect,iAlt);
    F(:,:,iAlt) = full(sys.A{1}); %#ok<*AGROW>
    G(:,:,iAlt) = full(sys.B{1});
    H(:,1,iAlt) = full(sys.K{1});
    J(:,:,iAlt) = full(sys.E{1});
    A(:,:,iAlt) = full(sys.A{2});
    B(:,:,iAlt) = full(sys.B{2});
    C(:,1,iAlt) = full(sys.K{2});
    D(:,:,iAlt) = full(sys.E{2});
end

% Lists of measurement variables, backward-looking transition variables, and
% forward-looking transition variables.
List = { ...
    This.solutionvector{1}, ...
    myvector(This,This.systemid{2} + 1i), ...
    This.solutionvector{3}, ...
    };

% Number of forward-looking variables.
NF = sum(imag(This.systemid{2}) >= 0);

end