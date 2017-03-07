function Y = myeval(This,Time,TRec,Lhs,LhsInpName,LhsStamp)
% myeval  [Not a public function] Return tseries value when evaluating time-recursive expressions.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if length(TRec.Dates) ~= length(This.TRec.Dates) ...
        || any(~datcmp(TRec.Dates,This.TRec.Dates))
    utils.error('tsydney:myeval', ...
        'Inconsistent date vectors in time-recursive expression.');
end

% Get the RHS tseries object.
Rhs = This.args;

% Check if `This` is the same tseries object as `Lhs`. Test two conditions:
% * the time stamp;
% * the input name.
% The test fails (false positive) in the following case
%
%     d.y = d.x;
%     d.x(t) = 0.8*d.y(t-1)
%
% behaves as if
%
%     d.x(t) = 0.8*d.x(t-1)
%
% This happens only if two tseries with an identical stamp are stored in
% dbase (struct) or cell array (in which case `inputname(...)` returns an
% empty string).
%
% A workaround is to use any subscripted reference or operator/function on
% one of the series (to change the time stamp), apart from a plain
% assignment, e.g.
%
%     d.y = d.x{:};
%     d.y = 1*d.x;
%

if isequal(Rhs.Stamp,LhsStamp) && isequal(This.InpName,LhsInpName)
    Rhs = Lhs;
end

sh = This.TRec.Shift;
Y = subsref(Rhs,Time+sh,This.Ref{:});

end
