function EstOpt=myoptimopts(EstOpt)
% myoptimoptions  [Not a public function]
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

solverName = '';
if ischar(EstOpt.solver)
    solverName = EstOpt.solver;
elseif isa(EstOpt.solver,'function_handle')
    solverName = func2str(EstOpt.solver);
elseif iscell(EstOpt.solver)
    if is.func(EstOpt.solver{1})
        solverName = func2str(EstOpt.solver{1});
    else
        solverName = char(EstOpt.solver{1});
    end
end
switch lower(solverName)
    case 'pso'
        if strcmpi(EstOpt.nosolution,'error')
            utils.warning('estimateobj', ...
                ['Global optimization algorithm, ', ...
                'switching from ''noSolution=error'' to ', ...
                '''noSolution=penalty''.']);
            EstOpt.nosolution = 'penalty';
        end
    case {'fmin','fmincon','fminunc','lsqnonln'}
        switch lower(solverName)
            case 'lsqnonlin'
                algorithm = 'levenberg-marquardt';
            otherwise
                algorithm = 'active-set';
        end
        oo = {...
            'algorithm',algorithm, ...
            'display',EstOpt.display, ...
            'maxIter',EstOpt.maxiter, ...
            'maxFunEvals',EstOpt.maxfunevals, ...
            'GradObj','off', ...
            'Hessian','off', ...
            'LargeScale','off', ...
            'tolFun',EstOpt.tolfun, ...
            'tolX',EstOpt.tolx, ...
            };
        if ~isempty(EstOpt.optimset) && iscell(EstOpt.optimset)
            oo = [oo,EstOpt.optimset];
        end
        oo(1:2:end) = strrep(oo(1:2:end),'=','');
        EstOpt.optimset = optimset(oo{:});
    otherwise
        % Do nothing.
end
end % doOptimOptions()
