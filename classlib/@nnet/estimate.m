function [This,xF,Obj] = estimate(This,Data,Range,varargin)

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
options = optim.myoptimopts(options) ;
options.Select = nnet.myalias(options.Select) ;
options.Select = sort(options.Select) ;

% Display
if ~strcmpi(options.display,'off') 
    fprintf(1,'\nEstimating neural network: \n') ;
    
    % Activation
    tf = any(strcmpi(options.Select,'activation')) ;
    fprintf(1,'\t[%g] activation parameters\n', ...
        tf*This.nActivationParams) ;
    
    % Hyper
    tf = any(strcmpi(options.Select,'hyper')) ;
    fprintf(1,'\t[%g] hyper parameters\n', ...
        tf*This.nHyperParams) ;
    
    % Output
    tf = any(strcmpi(options.Select,'output')) ;
    fprintf(1,'\t[%g] output parameters\n', ...
        tf*This.nOutputParams) ;
end

% Setup initial parameter vector and bounds
lb = [] ;
ub = [] ;
x0 = [] ;
for iOpt = 1:numel(options.Select) 
    switch options.Select{iOpt}
        case 'activation'
            bounds = get(This,'activationbounds') ;
            lb = [lb; bounds(:,1)] ;
            ub = [ub; bounds(:,2)] ;
            x0 = [x0; get(This,'activation')] ;
                
        case 'hyper'
            bounds = get(This,'hyperbounds') ;
            lb = [lb; bounds(:,1)] ;
            ub = [ub; bounds(:,2)] ;
            x0 = [x0; get(This,'hyper')] ;

        case 'output'
            bounds = get(This,'outputbounds') ;
            lb = [lb; bounds(:,1)] ;
            ub = [ub; bounds(:,2)] ;
            x0 = [x0; get(This,'output')] ; %#ok<*AGROW>

    end
end

% Get data
[InData,OutData] = datarequest('Inputs,Outputs',This,Data,Range) ;

if ischar(options.solver)
    % Optimization toolbox
    %----------------------
    if strncmpi(options.solver,'fmin',4)
        if all(isinf(lb)) && all(isinf(ub))
            [xF,Obj] = ...
                fminunc(@objfunc,x0,options.optimset, ...
                This,InData,OutData,Range,options); %#ok<ASGLU>
        else
            [xF,Obj] = ...
                fmincon(@objfunc,x0, ...
                [],[],[],[],lb,ub,[],options.optimset,...
                This,InData,OutData,Range,options); %#ok<ASGLU>
        end
    elseif strcmpi(options.solver,'lsqnonlin')
        [xF,Obj] = ...
            lsqnonlin(@objfunc,x0,lb,ub,options.optimset, ...
            This,InData,OutData,Range,options);
    elseif strcmpi(options.solver,'pso')
        % IRIS Optimization Toolbox
        %--------------------------
        [xF,Obj] = ...
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
    [xF,Obj] = ...
        f(@(x) objfunc(x,This,InData,OutData,Range,options), ...
        x0,lb,ub,options.optimset,args{:});
end

Xcount = 0 ;
for iOpt = 1:numel(options.Select) 
    switch options.Select{iOpt}
        case 'activation'
            This = set(This,'activation',xF(1:This.nActivationParams)) ;
            Xcount = This.nActivationParams ;
                
        case 'hyper'
            This = set(This,'hyper',xF(Xcount+1:Xcount+This.nHyperParams)) ;
            Xcount = Xcount + This.nHyperParams ;
            
        case 'output'
            This = set(This,'output',xF(Xcount+1:Xcount+This.nOutputParams)) ;

    end
end

end

