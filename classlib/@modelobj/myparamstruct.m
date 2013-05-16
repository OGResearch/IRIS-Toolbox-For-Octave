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

type = nan(size(list));
assignVal = nan(size(list));
stdcorrVal = nan(size(list));
for i = 1 : numel(list)
    if ~isnan(assignPos(i))
        type(i) = This.nametype(assignPos(i));
        assignVal(i) = This.Assign(assignPos(i));
    elseif ~isnan(stdcorrPos(i))
        type(i) = 4;
        stdcorrVal(i) = This.stdcorr(stdcorrPos(i));
    end
end

% Reset values of parameters and stdcorrs.
Pri.Assign = This.Assign;
Pri.stdcorr = This.stdcorr;

% Parameters to estimate and their positions.
Pri.plist = list(type == 4);
Pri.assignpos  = assignPos(type == 4);
Pri.stdcorrpos = stdcorrPos(type == 4);
np = length(Pri.plist);

Pri.p0 = nan(1,np);
Pri.pl = nan(1,np);
Pri.pu = nan(1,np);
Pri.prior = cell(1,np);
Pri.priorindex = false(1,np);

validBounds = true(1,np);
withinBounds = true(1,np);
doParameters();
doChkBounds();

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
            % If `NaN`, use the currently assigned value.
            if isnan(p0)
                if ~isnan(assignPos(ii))
                    p0 = assignVal(1,ii,:);
                else
                    p0 = stdcorrVal(1,ii,:);
                end
            end
            
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
            % Check that the lower bound is really lower than the upper bound.
            if pl >= pu
                validBounds(ii) = false;
                continue
            end
            % Check that the starting values in within the bounds.
            if p0 < pl || p0 > pu
                withinBounds(ii) = false;
                continue
            end
            
            % Prior distribution function, function_handle, or penalty
            % function, [weight] or [weight,pbar].
            isPrior = false;
            prior = [];
            if length(spec) > 3 && ~isempty(spec{4})
                isPrior = true;
                if isa(spec{4},'function_handle')
                    % The 4th entry is a prior distribution function handle.
                    prior = spec{4};
                elseif isnumeric(spec{4}) && Penalty > 0
                    doPenalty2Prior();
                end
            end
            
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
                if ~isnan(assignPos(ii))
                    pBar = assignVal(1,ii,:);
                else
                    pBar = stdcorrVal(1,ii,:);
                end
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
        if any(~validBounds)
            utils.error(class(This), ...
                ['Lower and upper bounds for this parameter ', ...
                'are inconsistent: ''%s''.'], ....
                Pri.plist{~validBounds});
        end
        
        if any(~withinBounds)
            utils.error(class(This), ...
                ['Starting value for this parameter is ', ...
                'outside the specified bounds: ''%s''.'], ....
                Pri.plist{~withinBounds});
        end
    end % doChkBounds().

end