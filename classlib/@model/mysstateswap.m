function This = mysstateswap(This,Opt)
% mysstateswap  [Not a public function] Swap endogeneity and exogeneity of some parameters and some transition variables for steady-state solver.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

endo = Opt.endogenise;
exo = Opt.exogenise;

if isempty(endo) && isempty(exo)
    return
end
if ~isempty(endo) && ischar(endo)
    endo = regexp(endo,'\w+','match');
end
if ~isempty(exo) && ischar(exo)
    exo = regexp(exo,'\w+','match');
end

endoPos = mynameposition(This,endo);
exoPos = mynameposition(This,exo);
endoValid = ~isnan(endoPos);
exoValid = ~isnan(exoPos);

doChkValid();

% Swap the variables and parameters.
This.nametype(endoPos) = 2;
This.nametype(exoPos) = 4;

inx = any(isnan(This.Assign(1,exoPos,:)),3);
if any(inx)
    utils.error('model', ...
        'This variable is exogenised to NaN: ''%s''.', ...
        This.name{exoPos(inx)});
end

% Nested functions.

%**************************************************************************
    function doChkValid()
        if all(endoValid)
            endoValid = This.nametype(endoPos) == 4;
        end
        if all(exoValid)
            exoValid = This.nametype(exoPos) == 2;
        end
        if any(~endoValid)
            utils.error('model', ...
                'Cannot endogenise this name: ''%s''.', ...
                endo{~endoValid});
        end
        if any(~exoValid)
            utils.error('model', ...
                'Cannot exogenise this name: ''%s''.', ...
                exo{~exoValid});
        end
        nEndo = length(endo);
        nExo = length(exo);
        if nEndo ~= nExo
            utils.error('model', ...
                ['The number of exogenised variables and the number ', ...
                'endogenised parameters must match.']);
        end
    end % doChkValid().

end