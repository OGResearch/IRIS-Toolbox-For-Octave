function This = saveobj(This)
% saveobj  [Not a public function] Prepare model object for saving.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

This = saveobj@modelobj(This);

% Convert function handles to char to minimise disk space needed.

% Do not convert `This.eqtnN` as this is a transient property.

% Extract the converted equations into local variables to speed up the
% executiona considerably. This is a Matlab issue.

eqtnF = This.eqtnF;
dEqtnF = This.DEqtnF;
cEqtnF = This.CEqtnF;

nEqtn = length(This.eqtn);
for iEqtn = 1 : nEqtn

    if isa(eqtnF{iEqtn},'function_handle')
        eqtnF{iEqtn} = func2str(eqtnF{iEqtn});
    end
    
    if isa(dEqtnF{iEqtn},'function_handle')
        dEqtnF{iEqtn} = func2str(dEqtnF{iEqtn});
    elseif iscell(dEqtnF{iEqtn})
        for j = 1 : length(dEqtnF{iEqtn})
            if isa(dEqtnF{iEqtn}{j},'function_handle');
                dEqtnF{iEqtn}{j} = func2str(dEqtnF{iEqtn}{j});
            end
        end
    end
    
    if isa(cEqtnF{iEqtn},'function_handle')
        cEqtnF{iEqtn} = func2str(cEqtnF{iEqtn});
    end
    
end

This.eqtnF = eqtnF;
This.DEqtnF = dEqtnF;
This.CEqtnF = cEqtnF;

end