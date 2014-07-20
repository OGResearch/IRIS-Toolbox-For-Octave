function [This,PStar,ObjStar,PCov,Hess] = myestimate(This,Data,Pri,EstOpt,LikOpt)
% myestimate  [Not a public function] Estimate parameters.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Set Optimization Toolbox options structure.
EstOpt = optim.myoptimopts(EstOpt) ;

%--------------------------------------------------------------------------

np = length(Pri.plist);

PStar = nan(1,np);
ObjStar = NaN;
Hess = {zeros(np),zeros(np),zeros(np)};
PCov = nan(np);

% Indicator of bounds hit for each parameter: 0 means interior optimum,
% -1 lower bound hit, +1 upper bound hit.
bhit = zeros(1,np);

if ~isempty(Pri.p0)

    np = length(Pri.p0);
    
    % The vectors `assign` and `stdcorr` are used in `objfunc` to reset
    % the model's parameterisation. This is to make sure that the `obj`
    % handle returned as an output of `estimate` will be not be affected by
    % re-scaling the std devs in the output model object. Make sure the
    % model is solved in the very first run.
    LAMBDA = [];
    if ischar(EstOpt.solver)
        % Optimization toolbox
        %----------------------
        if strncmpi(EstOpt.solver,'fmin',4)
            if all(isinf(Pri.pl)) && all(isinf(Pri.pu))
                [PStar,ObjStar,~,~,grad,Hess{1}] = ...
                    fminunc(@objfunc,Pri.p0,EstOpt.optimset, ...
                    This,Data,Pri,EstOpt,LikOpt); %#ok<ASGLU>
                LAMBDA = struct('lower',zeros(np,1),'upper',zeros(np,1));
            else
                [PStar,ObjStar,~,~,LAMBDA,grad,Hess{1}] = ...
                    fmincon(@objfunc,Pri.p0, ...
                    [],[],[],[],Pri.pl,Pri.pu,[],EstOpt.optimset,...
                    This,Data,Pri,EstOpt,LikOpt); %#ok<ASGLU>
            end
        elseif strcmpi(EstOpt.solver,'lsqnonlin')
            [PStar,ObjStar,~,~,~,LAMBDA] = ...
                lsqnonlin(@objfunc,Pri.p0,Pri.pl,Pri.pu,EstOpt.optimset, ...
                This,Data,Pri,EstOpt,LikOpt);
        elseif strcmpi(EstOpt.solver,'pso')
            % IRIS Optimization Toolbox
            %--------------------------
            [PStar,ObjStar,~,~,~,~,LAMBDA] = ...
                optim.pso(@objfunc,Pri.p0,[],[],[],[],...
                Pri.pl,Pri.pu,[],EstOpt.optimset,...
                This,Data,Pri,EstOpt,LikOpt);
        end
    else
        % User-supplied optimisation routine
        %------------------------------------
        if isa(EstOpt.solver,'function_handle')
            % User supplied function handle.
            f = EstOpt.solver;
            args = {};
        else
            % User supplied cell `{func,arg1,arg2,...}`.
            f = EstOpt.solver{1};
            args = EstOpt.solver(2:end);
        end
        [PStar,ObjStar,Hess{1}] = ...
            f(@(x) objfunc(x,This,Data,Pri,EstOpt,LikOpt), ...
            Pri.p0,Pri.pl,Pri.pu,EstOpt.optimset,args{:});
    end
    
    if isstruct(LAMBDA)
        % Find lower or upper bound hits.
        bhit(double(LAMBDA.lower) ~= 0) = -1;
        bhit(double(LAMBDA.upper) ~= 0) = 1;
    else
        bhit(PStar <= Pri.pl) = -1;
        bhit(PStar >= Pri.pu) = 1;
    end        
    
    % Fix numerical inaccuracies since `fmincon` sometimes returns
    % values numerically below lower bounds or above upper bounds.
    doChkBounds();
    
    % Initial proposal covariance matrix and contributions of priors to
    % Hessian.
    [PCov,Hess] = mydiffprior(This,Data,PStar,Hess,bhit,Pri,EstOpt,LikOpt);
    
else
    
    % No parameters to be estimated.
    utils.warning('model','No parameters to be estimated.');
    
end


% Nested functions...


%**************************************************************************
    function doChkBounds()
        below = PStar < Pri.pl;
        above = PStar > Pri.pu;
        if any(below)
            belows = {};
            for ii = find(below)
                belows = [belows,{ ...
                    PStar(ii),Pri.pl(ii)-PStar(ii),Pri.plist{ii} ...
                    }]; %#ok<AGROW>
            end
            utils.warning('model', ...
                ['Final estimate (%g) for this parameter is ', ...
                'numerically below its lower bound by a margin of %g ', ...
                'and will be reset: ''%s''.'], ...
                belows{:});
        end
        if any(above)
            aboves = {};
            for ii = find(above)
                aboves = [aboves,{ ...
                    PStar(ii),PStar(ii)-Pri.pu(ii),Pri.plist{ii} ...
                    }]; %#ok<AGROW>
            end
            utils.warning('model', ...
                ['Final estimate (%g) for this parameter is ', ...
                'numerically above its upper bound by a margin of %g ', ...
                'and will be reset: ''%s''.'], ...
                aboves{:});
        end
        % Reset the out-of-bounds values.
        PStar(below) = Pri.pl(below);        
        PStar(above) = Pri.pu(above);
    end % doChkBounds()


end