function Pri = myparamstruct(This,E,Pri,StartIfNan,Penalty,InitVal)

if isempty(InitVal)
    InitVal = 'struct';
end

%--------------------------------------------------------------------------

np = length(Pri.plist);

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

% Remove parameter fields and return a struct with non-parameter fields.
E = rmfield(E,Pri.plist);


% Nested functions...


%**************************************************************************
    function doParameters()
        for ii = 1 : np
            name = Pri.plist{ii};
            spec = E.(name);
            if isnumeric(spec)
                spec = num2cell(spec);
            end
            
            % Starting value.
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
                p0 = StartIfNan(ii);
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
                pBar = StartIfNan(ii);
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


end