function Flag = myisvalidinpdata(This,Inp)
% myisvalidinpdata  [Not a public function] Validate input data for VAR objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(Inp)
    Flag = true;
    return
end

ny = size(This.A,1);
if ispanel(This)
    % Panel VAR; only dbase inputs are accepted.
    Flag = isstruct(Inp);
    nGrp = length(This.GroupNames);
    for iGrp = 1 : nGrp
        name = This.GroupNames{iGrp};
        Flag = Flag && isfield(Inp,name) && isstruct(Inp.(name));
    end
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