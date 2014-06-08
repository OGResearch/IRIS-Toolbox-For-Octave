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
        if isempty(S(i).sstatelhs{j}) && isempty(S(i).sstaterhs{j}) ...
                && isempty(S(i).sstatesign{j})
            continue
        end
        S(i).eqtnlhs{j} = S(i).sstatelhs{j};
        S(i).eqtnrhs{j} = S(i).sstaterhs{j};
        S(i).eqtnsign{j} = S(i).sstatesign{j};
        S(i).sstatelhs{j} = '';
        S(i).sstaterhs{j} = '';
        S(i).sstatesign{j} = '';
        pos = strfind(S(i).eqtn{j},'!!');
        if ~isempty(pos)
            S(i).eqtn{j}(1:pos+1) = '';
        end
    end
end

end