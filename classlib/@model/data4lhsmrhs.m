function [YXE,List,XRange] = data4lhsmrhs(This,D,Range)
% data4lhsmrhs  Prepare data array for running `lhsmrhs`.
%
% Syntax
% =======
%
%     [YXE,List,XRange] = data4lhsmrhs(M,D,Range)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose equations will be later evaluated by
% calling [`lhsmrhs`](model/lhsmrhs).
%
% * `D` [ struct ] - Input database with observations on measurement
% variables, transition variables, and shocks on which
% [`lhsmrhs`](model/lhsmrhs) will be evaluated.
%
% * `Range` [ numeric ] - Date range on which [`lhsmrhs`](model/lhsmrhs)
% will be evaluated.
%
% Output arguments
% =================
% 
% * `YXE` [ numeric ] - Numeric array with the observations on measurement
% variables, transition variables, and shocks organised row-wise.
%
% * `List` [ cellstr ] - List of measurement variables, transition
% variables and shocks in order of their appearance in the rows of `YXE`.
%
% * `XRange` [ numeric ] - Extended range including pre-sample and
% post-sample observations needed to evaluate lags and leads of transition
% variables.
%
% Description
% ============
%
% The resulting array, `YXE`, is `nVar` by `nXPer` by `nData`, where `nVar`
% is the total number of measurement variables, transition variables, and
% shocks, `nXPer` is the number of periods including the pre-sample and
% post-sample periods needed to evaluate lags and leads, and `nData` is the
% number of alternative data sets (i.e. the number of columns in each input
% time series) in the input database, `D`.
%
% Example
% ========
%
%     YXE = data4lhsmrhs(M,d,range);
%     D = lhsmrhs(M,YXE);
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

List = This.name(This.nametype < 4);

minT = This.Shift(1);
maxT = This.Shift(end);
XRange = Range(1)+minT : Range(end)+maxT;

YXE = db2array(D,List,XRange);
YXE = permute(YXE,[2,1,3]);

end
