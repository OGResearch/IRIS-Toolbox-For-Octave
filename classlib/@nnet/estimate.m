function Obj = estimate(This,Data,Range,varargin)

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

pp = inputParser() ;
pp.addRequired('This',@(x) isa(x,'nnet')) ;
pp.addRequired('Data',@isstruct) ;
pp.addRequired('Range',@(x) isnumeric(x) && isvector(x)) ;
pp.parse(This,Data,Range) ;
if This.nAlt>1
    utils.error('nnet:estimate',...
        'Estimate does not support input neural network objects with multiple parameterizations.') ;
end

% Parse options
options = passvalopt('nnet.estimate',varargin{:}) ;

% Get data
[InData,OutData] = datarequest('Inputs,Outputs',This,Data,Range) ;

% Test objective function
% Obj = objfunc(This,InData,OutData,Range,options) ;

if ischar(options.solver)
    % Optimization toolbox
    %----------------------
    if strncmpi(options.solver,'fmin',4)
        if all(isinf(lb)) && all(isinf(ub))
            [PStar,ObjStar] = ...
                fminunc(@objfunc,x0,options.optimset, ...
                This,InData,OutData,Range,options); %#ok<ASGLU>
        else
            [PStar,ObjStar] = ...
                fmincon(@objfunc,x0, ...
                [],[],[],[],lb,ub,[],options.optimset,...
                This,InData,OutData,Range,options); %#ok<ASGLU>
        end
    elseif strcmpi(options.solver,'lsqnonlin')
        [PStar,ObjStar] = ...
            lsqnonlin(@objfunc,x0,lb,ub,options.optimset, ...
            This,InData,OutData,Range,options);
    elseif strcmpi(options.solver,'pso')
        % IRIS Optimization Toolbox
        %--------------------------
        [PStar,ObjStar] = ...
            optim.pso(@objfunc,x0,[],[],[],[],...
            lb,ub,[],options.optimset,...
            This,InData,OutData,Range,options);
    end
else
    % User-supplied optimisation routine
    %------------------------------------
    if isa(options.solver,'function_handle')
        % User supplied function handle.
        f = options.solver;
        args = {};
    else
        % User supplied cell `{func,arg1,arg2,...}`.
        f = options.solver{1};
        args = options.solver(2:end);
    end
    [PStar,ObjStar] = ...
        f(@(x) objfunc(x,This,InData,OutData,Range,options), ...
        x0,lb,ub,options.optimset,args{:});
end

end

