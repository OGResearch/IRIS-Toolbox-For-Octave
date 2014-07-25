function [Eqtn,EqtnLabel,EqtnLhs,EqtnRhs,EqtnSign, ...
    SstateLhs,SstateRhs,SstateSign, ...
    MaxT,MinT,InvalidTimeSubs,EmptyEqtn] = parseeqtns(This,Blk)
% parseeqtns [Not a public function] Parse equations within an equation block.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

EqtnLabel = cell(1,0);
EqtnLhs = cell(1,0);
EqtnRhs = cell(1,0);
EqtnSign = cell(1,0);
SstateLhs = cell(1,0);
SstateRhs = cell(1,0);
SstateSign = cell(1,0);
MaxT = 0;
MinT = 0;
InvalidTimeSubs = cell(1,0);
EmptyEqtn = cell(1,0);

%--------------------------------------------------------------------------

Blk = strrep(Blk,sprintf('\n'),'');
Blk = strrep(Blk,sprintf('\r'),'');
Blk = strrep(Blk,sprintf('\t'),'');
Blk = strrep(Blk,' ','');
Blk = strrep(Blk,'!ttrend','ttrend');

% Split the block into individual equations.
Eqtn = regexp(Blk,'[^;]+;','match');
if isempty(Eqtn)
    Eqtn = cell(1,0);
    return
end

% Validate and evaluate time subscripts.
[tempEqtn,MaxT,MinT,validTimeSubs] = evaltimesubs(This,Eqtn);
if any(~validTimeSubs)
    InvalidTimeSubs = Eqtn(~validTimeSubs);
    return
end

% Parse the structure of individual equations.
ptn = [ ...
    '((',regexppattern(This.Labels),')?)', ... % Label.
    '([^!;',This.Labels.CharUsed,']*)', ... % Full eqtn.
    '((!![^!;',This.Labels.CharUsed,']*)?);', ... % Sstate.
    ]; 
tkn = regexp(tempEqtn,ptn,'tokens','once');
if true % ##### MOSW
    % Do nothing
else
    % Check for Octave regexp bug -- very first unmatched token is not recorded
    % in resulting cell at all, even if token is enclosed in extra parentheses
    for ix = 1 : numel(tkn)
        if numel(tkn{ix}) == 2
            tkn{ix} = [''; tkn{ix}];
        end
    end
end
tkn = [tkn{:}];

EqtnLabel = tkn(1:3:end);
eqtnOnly = tkn(2:3:end);
sstate = tkn(3:3:end);
sstate = strrep(sstate,'!!','');

% Remove equations that consist of labels only; throw a warning later.
isEmptyEqtn = cellfun(@isempty,eqtnOnly) & cellfun(@isempty,sstate);
if any(isEmptyEqtn)
    EmptyEqtn = Eqtn(isEmptyEqtn);
    Eqtn(isEmptyEqtn) = [];
    eqtnOnly(isEmptyEqtn) = [];
    sstate(isEmptyEqtn) = [];
end

% Split equations into LHS, sign, and RHS.
[EqtnLhs,EqtnRhs,EqtnSign] = xxEqualSign(eqtnOnly);
[SstateLhs,SstateRhs,SstateSign] = xxEqualSign(sstate);

end


% Subfunctions...


%**************************************************************************


function [Lhs,Rhs,Sign] = xxEqualSign(List)
nList = length(List);
Lhs = strfun.emptycellstr(1,nList);
Rhs = strfun.emptycellstr(1,nList);
Sign = strfun.emptycellstr(1,nList);
[start,finish] = regexp(List,':=|=#|\+=|=','once','start','end');
for i = 1 : nList
    if ~isempty(start{i})
        Lhs{i} = List{i}(1:start{i}-1);
        Rhs{i} = List{i}(finish{i}+1:end);
        Sign{i} = List{i}(start{i}:finish{i});
    else
        Rhs{i} = List{i};
    end
end
end % xxEqualSign()
