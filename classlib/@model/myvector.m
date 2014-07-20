function Vec = myvector(This,Type)
% myvector  [Not a public function] Vectors of variables in the state space.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ischar(Type)
    Vec = cell(1,0);
    IxLog = false(1,0);
    for iType = lower(Type)
        switch iType
            case 'y'
                % Vector of measurement variables.
                inx = This.nametype == 1;
                Vec = [Vec,This.name(inx)]; %#ok<AGROW>
                IxLog = [IxLog,This.IxLog(inx)]; %#ok<AGROW>
            case 'x'
                % Vector of transition variables.
                pos = real(This.solutionid{2});
                shift = imag(This.solutionid{2});
                iVec = This.name(pos);
                for i = find(shift ~= 0)
                    iVec{i} = sprintf('%s{%g}',iVec{i},shift(i));
                end
                Vec = [Vec,iVec]; %#ok<AGROW>
                IxLog = [IxLog,This.IxLog(pos)]; %#ok<AGROW>
            case 'e'
                % Vector of shocks.
                inx = This.nametype == 3;
                Vec = [Vec,This.name(inx)]; %#ok<AGROW>
                IxLog = [IxLog,This.IxLog(inx)]; %#ok<AGROW>
            case 'g'
                % Vector of exogenous variables.
                inx = This.nametype == 5;
                Vec = [Vec,This.name(inx)]; %#ok<AGROW>
                IxLog = [IxLog,This.IxLog(inx)]; %#ok<AGROW>
        end
    end
else
    pos = real(Type);
    shift = imag(Type);
    Vec = This.name(pos);
    for i = find(shift ~= 0)
        Vec{i} = sprintf('%s{%g}',Vec{i},shift(i));
    end
    IxLog = This.IxLog(pos);
end

% Wrap log-variables in 'log(...)'.
if any(IxLog)
    Vec(IxLog) = regexprep(Vec(IxLog),'(.*)','log($1)');
end

end
