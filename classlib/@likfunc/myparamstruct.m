function Pri = myparamstruct(This,X,E)
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

% Parameters to estimate and their positions; remove names that are not
% valid parameter names.
paramPos = strfun.findnames(This.name(This.nameType == 2),list);
paramPos = paramPos(:).';
isValidParamName = ~isnan(paramPos);
% Total number of parameter names to estimate.
np = sum(isValidParamName);

% Parameter priors
%------------------
Pri.plist = list(isValidParamName);
Pri.paramPos  = paramPos(isValidParamName);

% Starting value
%----------------
% Prepare the values of the estimated parameters from the input database;
% these are used whenever the starting value in the estimation struct is
% `NaN`.
P = [X{This.nameType == 2}];
startIfNan = P(Pri.paramPos);

% Estimation struct can include names that are not valid parameter names;
% throw a warning for them.
doReportInvalidNames();

Pri = myparamstruct@estimateobj(This,E,Pri,startIfNan,0,[]);

% Nested functions...


%**************************************************************************
    function doReportInvalidNames()
        if any(~isValidParamName)
            invalidNameList = list(~isValidParamName);
            utils.warning('modelobj', ...
                ['This name in the estimation struct is not ', ...
                'a valid parameter name: ''%s''.'], ...
                invalidNameList{:});
        end
    end % doReportInvalidNames()


end