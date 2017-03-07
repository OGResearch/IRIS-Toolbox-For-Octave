function Flag = myisvalidinpdata(This,Inp)
% myisvalidinpdata  [Not a public function] Validate input data for VAR objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(Inp)
    Flag = true;
    return
end

ny = size(This.A,1);
if ispanel(This)
    % Panel VAR; only dbase inputs are accepted.
    isStruct = isstruct(Inp);
    nGrp = length(This.GroupNames);
    isGrpStruct = false(1,nGrp);
    if isStruct
        for iGrp = 1 : nGrp
            name = This.GroupNames{iGrp};
            isGrpStruct(iGrp) = isfield(Inp,name) && isstruct(Inp.(name));
        end
    end
    if any(~isGrpStruct)
        utils.warning('VAR:myisvalidinpdata', ...
            'This group is missing from input database: ''%s''.', ...
            This.GroupNames{~isGrpStruct});
    end
    Flag = isStruct && all(isGrpStruct);
else
    % Non-panel VAR; both dbase and tseries inputs are accepted for bkw
    % compatibility.
    if isstruct(Inp)
        Flag = true;
    elseif isa(Inp,'tseries')
        Flag = (ny == 0 || size(Inp,2) == ny || size(Inp,2) == 2*ny);
    else
        Flag = false;
    end
end

end