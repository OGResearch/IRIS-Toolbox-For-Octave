function S = findsegments(S)
% findsegments  [Not a public function] Detect segmentation by unanticipated shocks.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

S.segment = 1;
% Positions of unanticipated shocks (segments) or unanticipated endogenised
% shocks.
temp = S.unantFunc(S.e) ~= 0;
if ~isempty(S.EuAnch)
    temp = [temp;S.EuAnch];
end
S.segment = find(any(temp,1));
if isempty(S.segment) || S.segment(1) ~= 1
    S.segment = [1,S.segment];
end

end