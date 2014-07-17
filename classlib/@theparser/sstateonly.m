function S = sstateonly(S)
% sstateonly  [Not a public function] Replace full equations with steady-state equatoins when present.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

for i = 1 : length(S)
    if isempty(S(i).eqtn)
        continue
    end
    for j = 1 : length(S(i).eqtn)
        if isempty(S(i).SstateLhs{j}) && isempty(S(i).SstateRhs{j}) ...
                && isempty(S(i).SstateSign{j})
            continue
        end
        S(i).EqtnLhs{j} = S(i).SstateLhs{j};
        S(i).EqtnRhs{j} = S(i).SstateRhs{j};
        S(i).EqtnSign{j} = S(i).SstateSign{j};
        S(i).SstateLhs{j} = '';
        S(i).SstateRhs{j} = '';
        S(i).SstateSign{j} = '';
        pos = strfind(S(i).eqtn{j},'!!');
        if ~isempty(pos)
            S(i).eqtn{j}(1:pos+1) = '';
        end
    end
end

end