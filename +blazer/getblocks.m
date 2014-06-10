function [NameBlk,EqtnBlk] = getblocks(Occ,OrdName,OrdEqtn)
% getblocks  [Not a public function] Names and equations in individual recursive blocks.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

n = size(Occ,1);
NameBlk = {};
EqtnBlk = {};
currNameBlk = [];
currEqtnBlk = [];
for i = n : -1 : 1
    currNameBlk(end+1) = OrdName(i); %#ok<AGROW>
    currEqtnBlk(end+1) = OrdEqtn(i); %#ok<AGROW>
    if ~any(any(Occ(i:end,1:i-1)))
        NameBlk{end+1} = currNameBlk; %#ok<AGROW>
        EqtnBlk{end+1} = currEqtnBlk; %#ok<AGROW>
        currNameBlk = [];
        currEqtnBlk = [];
    end
end

end