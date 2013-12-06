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
if iscellstr(options.Estimate)
    options.Estimate = nnet.myalias(options.Estimate) ;
    % set default bounds
    options.lbWeight = -Inf ;
    options.ubWeight = Inf ;
    options.lbTransfer = 0 ;
    options.ubTransfer = Inf ;
    options.lbBias = -Inf ;
    options.ubBias = Inf ;
else
    Ecell = options.Estimate ;
    options.Estimate = cell(size(Ecell)) ;
    % user specified bounds
    for iOpt = 1:numel(Ecell)
        aname = nnet.myalias(Ecell{iOpt}{1}) ;
        switch aname                
            case 'bias'
                options.lbBias = Ecell{iOpt}{2} ;
                options.ubBias = Ecell{iOpt}{3} ;
                
            case 'transfer'
                options.lbTransfer = Ecell{iOpt}{2} ;
                options.ubTransfer = Ecell{iOpt}{3} ;
                
            case 'weight'
                options.lbWeight = Ecell{iOpt}{2} ;
                options.ubWeight = Ecell{iOpt}{3} ;

            otherwise
                utils.error('nnet:estimate',...
                    'Unrecognized group of parameters %s.\n',Ecell{iOpt}{1}) ;
        end
        options.Estimate{iOpt} = aname ;
    end
end
options.Estimate = sort(options.Estimate) ;

% Display
if ~strcmpi(options.display,'off') 
    fprintf(1,'\nEstimating neural network: \n') ;
    
    % Weight
    tf = any(strcmpi(options.Estimate,'weight')) ;
    fprintf(1,'\t[%g] weight parameters', ...
        tf*This.nWeight) ;
    if tf
        fprintf(1,' with bounds [%g,%g]\n',options.lbWeight,options.ubWeight) ;
    else
        fprintf(1,'\n') ;
    end
    
    % Bias
    tf = any(strcmpi(options.Estimate,'bias')) ;
    fprintf(1,'\t[%g] bias parameters', ...
        tf*This.nBias) ;
    if tf
        fprintf(1,' with bounds [%g,%g]\n',options.lbBias,options.ubBias) ;
    else
        fprintf(1,'\n') ;
    end
    
    % Transfer
    tf = any(strcmpi(options.Estimate,'transfer')) ;
    fprintf(1,'\t[%g] transfer parameters', ...
        tf*This.nTransfer) ;
    if tf
        fprintf(1,' with bounds [%g,%g]\n\n',options.lbTransfer,options.ubTransfer) ;
    else
        fprintf(1,'\n\n') ;
    end
end

% Setup initial parameter vector and bounds
lb = [] ;
ub = [] ;
x0 = [] ;
for iOpt = 1:numel(options.Estimate) 
    switch options.Estimate{iOpt}
        case 'bias'
            lb = [lb; options.lbBias*ones(This.nBias,1)] ;
            ub = [ub; options.ubBias*ones(This.nBias,1)] ;
            x0 = [x0; get(This,'bias')] ;
                
        case 'transfer'
            lb = [lb; options.lbTransfer*ones(This.nTransfer,1)] ;
            ub = [ub; options.ubTransfer*ones(This.nTransfer,1)] ;
            x0 = [x0; get(This,'transfer')] ;

        case 'weight'
            lb = [lb; options.lbWeight*ones(This.nWeight,1)] ;
            ub = [ub; options.ubWeight*ones(This.nWeight,1)] ;
            x0 = [x0; get(This,'weight')] ; %#ok<*AGROW>

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
for iOpt = 1:numel(options.Estimate) 
    switch options.Estimate{iOpt}
        case 'bias'
            This = set(This,'bias',xF(1:This.nBias)) ;
            Xcount = This.nBias ;
                
        case 'transfer'
            This = set(This,'transfer',xF(Xcount+1:Xcount+This.nTransfer)) ;
            Xcount = Xcount + This.nTransfer ;
            
        case 'weight'
            This = set(This,'weight',xF(Xcount+1:Xcount+This.nWeight)) ;

    end
end

end

