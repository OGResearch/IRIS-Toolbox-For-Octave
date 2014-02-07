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
deqtnF = This.deqtnF;
ceqtnF = This.ceqtnF;

nEqtn = length(This.eqtn);
for iEqtn = 1 : nEqtn

    if isa(eqtnF{iEqtn},'function_handle')
        eqtnF{iEqtn} = func2str(eqtnF{iEqtn});
    end
    
    if isa(deqtnF{iEqtn},'function_handle')
        deqtnF{iEqtn} = func2str(deqtnF{iEqtn});
    elseif iscell(deqtnF{iEqtn})
        for j = 1 : length(deqtnF{iEqtn})
            if isa(deqtnF{iEqtn}{j},'function_handle');
                deqtnF{iEqtn}{j} = func2str(deqtnF{iEqtn}{j});
            end
        end
    end
    
    if isa(ceqtnF{iEqtn},'function_handle')
        ceqtnF{iEqtn} = func2str(ceqtnF{iEqtn});
    end
    
end

This.eqtnF = eqtnF;
This.deqtnF = deqtnF;
This.ceqtnF = ceqtnF;

end