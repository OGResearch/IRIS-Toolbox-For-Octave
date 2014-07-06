function Pri = myparamstruct(This,E,SP,Penalty,InitVal)
% myparamstruct  [Not a public function] Parse structure with parameter estimation specs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Pri = struct();

% Remove empty entries from `E`.
list = fieldnames(E).';
nList = length(list);
remove = false(1,nList);
for i = 1 : nList
    if isempty(E.(list{i}))
        remove(i) = true;
    end
end
E = rmfield(E,list(remove));
list(remove) = [];

[assignPos,stdcorrPos] = mynameposition(This,list);

% Reset values of parameters and stdcorrs.
Pri.Assign = This.Assign;
Pri.stdcorr = This.stdcorr;

% Parameters to estimate and their positions; remove names that are not
% valid parameter names.
isValidParamName = ~isnan(assignPos) | ~isnan(stdcorrPos);
% Total number of parameter names to estimate.
np = sum(isValidParamName);

% System priors
%---------------
if isempty(SP)
    Pri.sprior = [];
else
    Pri.sprior = SP;
end

% Parameter priors
%------------------
Pri.plist = list(isValidParamName);
Pri.assignpos  = assignPos(isValidParamName);
Pri.stdcorrpos = stdcorrPos(isValidParamName);

% Starting value
%----------------
% Prepare the value currently assigned in the model object; this is used
% when the starting value in the estimation struct is `NaN`.
startIfNan = nan(1,np);
for i = 1 : np
    if ~isnan(Pri.assignpos(i))
        startIfNan(i) = This.Assign(Pri.assignpos(i));
    else
        startIfNan(i) = This.stdcorr(Pri.stdcorrpos(i));
    end
end

% Estimation struct can include names that are not valid parameter names;
% throw a warning for them.
doReportInvalidNames();

Pri = myparamstruct@estimateobj(This,E,Pri,startIfNan,Penalty,InitVal);

%**************************************************************************
    function doReportInvalidNames()
        if any(~isValidParamName)
            invalidNameList = list(~isValidParamName);
            utils.warning('modelobj', ...
                ['This name in the estimation struct is not ', ...
                'a valid parameter name: ''%s''.'], ...
                invalidNameList{:});
        end
    end % doReportInvalidNames().

end