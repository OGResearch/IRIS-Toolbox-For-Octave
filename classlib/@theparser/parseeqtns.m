function [Eqtn,EqtnLabel,EqtnLhs,EqtnRhs,EqtnSign, ...
    SstateLhs,SstateRhs,SstateSign] = parseeqtns(Blk)
% parseeqtns [Not a public function] Parse equations within an equation block.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

Blk = regexprep(Blk,'\s+','');
Blk = strrep(Blk,'!ttrend','ttrend');

pattern = [ ...
    '(?<label>#\(\d+\))?', ...
    '(?<eqtn>[^!;]*)', ...
    '(?<sstate>!![^!;]+)?;'];
[Eqtn,tok] = regexp(Blk,pattern,'match','names');

EqtnLabel = {tok(:).label};
eqtn = {tok(:).eqtn};
sstate = {tok(:).sstate};
sstate = strrep(sstate,'!!','');

[EqtnLhs,EqtnRhs,EqtnSign] = xxEqualSign(eqtn);
[SstateLhs,SstateRhs,SstateSign] = xxEqualSign(sstate);

end

% Subfunctions.

%**************************************************************************
function [Lhs,Rhs,Sign] = xxEqualSign(List)
nList = length(List);
Lhs = strfun.emptycellstr(1,nList);
Rhs = strfun.emptycellstr(1,nList);
Sign = strfun.emptycellstr(1,nList);
[start,finish] = regexp(List,'[:+]?=#?','once','start','end');
for i = 1 : nList
    if ~isempty(start{i})
        Lhs{i} = List{i}(1:start{i}-1);
        Rhs{i} = List{i}(finish{i}+1:end);
        Sign{i} = List{i}(start{i}:finish{i});
    else
        Rhs{i} = List{i};
    end
end
end % xxEqualSign().