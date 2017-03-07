function [YA,XA,EaReal,EaImag,YC,XC,QA,WReal,WImag] = myanchors(This,P,Range)
% myanchors  [Not a public function] Get simulation plan anchors for model variables.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Check date frequencies.
if datfreq(P.Start) ~= datfreq(Range(1)) ...
        || datfreq(P.End) ~= datfreq(Range(end))
    utils.error('model', ...
        'Simulation range and plan range must be the same frequency.');
end

% Adjust plan range to simulation range if not equal.
if ~datcmp(P.Start,Range(1)) ...
        || ~datcmp(P.End,Range(end))
    P = P(Range);
end

%--------------------------------------------------------------------------

ny = sum(This.nametype == 1);
nx = length(This.solutionid{2});
nPer = length(Range);
nEqtn = length(This.eqtn);

% Anchors for exogenised measurement variables, and conditioning measurement
% variables.
YA = P.XAnch(1:ny,:);
YC = P.CAnch(1:ny,:);

% Anchors for exogenised transition variables, and conditioning transition
% variables.
realId = real(This.solutionid{2});
imagId = imag(This.solutionid{2});
XA = false(nx,nPer);
XC = false(nx,nPer);
for j = find(This.nametype == 2)
    inx = realId == j & imagId == 0;
    XA(inx,:) = P.XAnch(j,:);
    XC(inx,:) = P.CAnch(j,:);
end

% Anchors for endogenised shocks.
EaReal = P.NAnchReal;
EaImag = P.NAnchImag;

% Anchors for non-linear equations.
QA = false(nEqtn,nPer);
QA(This.IxNonlin,:) = P.QAnch;
QA = any(QA,1);

WReal = P.NWghtReal;
WImag = P.NWghtImag;

end
