function [Pri,E] = myparamstruct(This,E,SP,Penalty,InitVal)
% myparamstruct  [Not a public function] Parse structure with parameter estimation specs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if isempty(InitVal)
    InitVal = 'struct';
end

%--------------------------------------------------------------------------

Pri = struct();

% System priors.
if isempty(SP)
    Pri.sprior = [];
else
    Pri.sprior = SP;
end

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

%{
type = nan(size(list));
assignVal = nan(size(list));
stdcorrVal = nan(size(list));
for i = 1 : numel(list)
    if ~isnan(assignPos(i))
        assignVal(i) = This.Assign(assignPos(i));
    elseif ~isnan(stdcorrPos(i))
        stdcorrVal(i) = This.stdcorr(stdcorrPos(i));
    end
end
%}

% Reset values of parameters and stdcorrs.
Pri.Assign = This.Assign;
Pri.stdcorr = This.stdcorr;

% Parameters to estimate and their positions; remove names that are not
% valid parameter names.
isValidParamName = ~isnan(assignPos) | ~isnan(stdcorrPos);
Pri.plist = list(isValidParamName);
Pri.assignpos  = assignPos(isValidParamName);
Pri.stdcorrpos = stdcorrPos(isValidParamName);

% Total number of parameter names to estimate.
np = sum(isValidParamName);

Pri.p0 = nan(1,np);
Pri.pl = nan(1,np);
Pri.pu = nan(1,np);
Pri.prior = cell(1,np);
Pri.priorindex = false(1,np);

isValidBounds = true(1,np);
isWithinBounds = true(1,np);
isPenaltyFunction = false(1,np);

doParameters();
doChkBounds();

% Penalty specification is obsolete.
doReportPenaltyFunc();

% Estimation struct can include names that are not valid parameter names;
% throw a warning for them.
doReportInvalidNames();

% Remove parameter fields and return a struct with non-parameter fields.
E = rmfield(E,Pri.plist);

% Nested functions.

%**************************************************************************
    function doParameters()
        for ii = 1 : np
            name = Pri.plist{ii};
            spec = E.(name);
            if isnumeric(spec)
                spec = num2cell(spec);
            end
            
            % Starting value
            %----------------
            % Prepare the value currently assigned in the model object; this is used
            % when the starting value in the estimation struct is `NaN`.
            assignIfNan = NaN;
            if ~isnan(Pri.assignpos(ii))
                assignIfNan = This.Assign(Pri.assignpos(ii));
            elseif ~isnan(Pri.stdcorrpos(ii))
                assignIfNan = This.stdcorr(Pri.stdcorrpos(ii));
            end
            
            if isstruct(InitVal) ...
                    && isfield(InitVal,name) ...
                    && isnumericscalar(InitVal.(name))
                p0 = InitVal.(name);
            elseif ischar(InitVal) && strcmpi(InitVal,'struct') ...
                    && ~isempty(spec) && isnumericscalar(spec{1})
                p0 = spec{1};
            else
                p0 = NaN;
            end
            % If the starting value is `NaN` at this point, use the currently assigned
            % value from the model object, `assignIfNan`.
            if isnan(p0)
                p0 = assignIfNan;
            end
            
            % Lower and upper bounds
            %------------------------
            % Lower bound.
            if length(spec) > 1 && isnumericscalar(spec{2})
                pl = spec{2};
            else
                pl = -Inf;
            end
            % Upper bound.
            if length(spec) > 2  && isnumericscalar(spec{3})
                pu = spec{3};
            else
                pu = Inf;
            end
            % Check that the lower bound is lower than the upper bound.
            if pl >= pu
                isValidBounds(ii) = false;
                continue
            end
            % Check that the starting values in within the bounds.
            if p0 < pl || p0 > pu
                isWithinBounds(ii) = false;
                continue
            end
            
            % Prior distribution function
            %-----------------------------
            
            % The 4th element in the estimation struct can be either a prior
            % distribution function (a function_handle) or penalty function, i.e. a
            % numeric vector [weight] or [weight,pbar]. The latter option is only for
            % bkw compatibility, and will be deprecated.
            isPrior = false;
            prior = [];
            if length(spec) > 3 && ~isempty(spec{4})
                isPrior = true;
                if isa(spec{4},'function_handle')
                    % The 4th element is a prior distribution function handle.
                    prior = spec{4};
                elseif isnumeric(spec{4}) && Penalty > 0
                    % The 4th element is a penalty function.
                    isPenaltyFunction(ii) = true;
                    doPenalty2Prior();
                end
            end
            
            % Populate the `Pri` struct
            %---------------------------
            Pri.p0(ii) = p0;
            Pri.pl(ii) = pl;
            Pri.pu(ii) = pu;
            Pri.prior{ii} = prior;
            Pri.priorindex(ii) = isPrior;
            
        end
        
        function doPenalty2Prior()
            % The 4th entry is a penalty function, compute the
            % total weight including the `'penalty='` option.
            totalWeight = spec{4}(1)*Penalty;
            if length(spec{4}) == 1
                % Only the weight specified. The centre of penalty
                % function is then set identical to the starting
                % value.
                pBar = p0;
            else
                % Both the weight and the centre specified.
                pBar = spec{4}(2);
            end
            if isnan(pBar)
                pBar = assignIfNan;
            end
            % Convert penalty function to a normal prior:
            %
            % w*(p - pbar)^2 == 1/2*((p - pbar)/sgm)^2 => sgm =
            % 1/sqrt(2*w).
            %
            sgm = 1/sqrt(2*totalWeight);
            prior = logdist.normal(pBar,sgm);
        end % doPenalty2Prior().
        
    end % doParameters().

%**************************************************************************
    function doChkBounds()
        % Report bounds where lower >= upper.
        if any(~isValidBounds)
            utils.error(class(This), ...
                ['Lower and upper bounds for this parameter ', ...
                'are inconsistent: ''%s''.'], ....
                Pri.plist{~isValidBounds});
        end
        % Report bounds where start < lower or start > upper.
        if any(~isWithinBounds)
            utils.error(class(This), ...
                ['Starting value for this parameter is ', ...
                'outside the specified bounds: ''%s''.'], ....
                Pri.plist{~isWithinBounds});
        end
    end % doChkBounds().

%**************************************************************************
    function doReportPenaltyFunc()
        if any(isPenaltyFunction)
            paramPenaltyList = Pri.plist(isPenaltyFunction);
            utils.warning('obsolete', ...
                ['This parameter prior is specified ', ...
                'as a penalty function: ''%s''. \n', ...
                'Penalty functions are obsolete and will be removed from ', ...
                'a future version of IRIS. ', ...
                'Replace them with normal prior distributions.'], ...
                paramPenaltyList{:});
        end
    end % doReportPenaltyFunc().

%**************************************************************************
    function doReportInvalidNames()
        if any(isValidParamName)
            invalidNameList = list(~isValidParamName);
            utils.warning('modelobj', ...
                ['This name in the estimation struct is not ', ...
                'a valid parameter name: ''%s''.'], ...
                invalidNameList{:});
        end
    end % doReportInvalidNames().

end