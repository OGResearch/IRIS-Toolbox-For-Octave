classdef poster < getsetobj
% poster  Posterior Simulator Objects and Functions.
%
% Posterior objects, `poster`, are used to evaluate the behaviour of the
% posterior dsitribution, and to draw model parameters from the posterior
% distibution.
%
% Posterior objects are set up within the
% [`model/estimate`](model/estimate) function and returned as the second
% output argument - the set up and initialisation of the posterior object
% is fully automated in this case. Alternatively, you can set up a
% posterior object manually, by setting all its properties appropriately.
%
% Poster methods:
%
% Constructor
% ============
%
% * [`poster`](poster/poster) - Create new, empty posterior simulation (poster) object.
%
% Evaluating posterior density
% =============================
%
% * [`arwm`](poster/arwm) - Adaptive random-walk Metropolis posterior simulator.
% * [`eval`](poster/eval) - Evaluate posterior density at specified points.
% * [`regen`](poster/regen) - Regeneration time MCMC Metropolis posterior simulator.
%
% Chain statistics
% =================
%
% * [`stats`](poster/stats) - Evaluate selected statistics of ARWM chain.
%
% Getting on-line help on model functions
% ========================================
%
%     help poster
%     help poster/function_name
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

    properties
        % Names of parameters.
        ParamList = {};
        
        % Objective function.
        MinusLogPostFunc = [];
        MinusLogPostFuncArgs = {};
        MinusLogLikFunc = [];
        MinusLogLikFuncArgs = {};
        LogPriorFunc = {};
        
        % Log posterior density at initial vector.
        InitLogPost = NaN;
        
        % Initial vector of parameters.
        InitParam = [];
        
        % Initial proposal cov matrix; will be multiplied by squared
        % `.InitScale`.
        InitProposalCov = [];
        
        % Cholesky factor of initial proposal cov matrix; if empty,
        % chol(...) is performed on `.InitProposalCov`.
        InitProposalChol = [];
        
        % Initial sqrt of factor by which cov matrix will be multiplied.
        InitScale = 1/3;
        
        % Initial counts of draws, acceptances, and burn-ins.
        InitCount = [0,0,0]; 
        
        % Lower and upper bounds on individual parameters.
        LowerBounds = [];
        UpperBounds = [];
    end
    
    methods
        
        function This = poster(varargin)
            % poster  Create new, empty posterior simulation (poster) object.
            %
            % Syntax
            % =======
            %
            %     P = poster()
            %
            % Description
            % ============
            %
            % Creating and initialising posterior simulation objects manually is
            % unnecessary. Posterior simulation objects are created and initialised
            % automatically within estimation methods of various other objects, such as
            % [`model/estimate`](model/estimate).
            %
            
            % -IRIS Toolbox.
            % -Copyright (c) 2007-2014 IRIS Solutions Team.
                        
            if isempty(varargin)
                return
            elseif length(varargin) == 1 && is.poster(varargin{1})
                This = varargin{1};
            elseif length(varargin) == 1 && isstruct(varargin{1})
                This = mystruct2obj(This,varargin{1});
            end
        end
        
        varargout = arwm(varargin)
        varargout = eval(varargin)
        varargout = stats(varargin)
        
        function This = set.ParamList(This,List)
            if ischar(List) || iscellstr(List)
                if ischar(List)
                    List = regexp(List,'\w+','match');
                end
                This.ParamList = List(:).';
                if length(This.ParamList) ~= length(unique(This.ParamList))
                    utils.error('poster:set:ParamList', ...
                        'Parameter names must be unique.');
                end
                n = length(This.ParamList);
                This.LogPriorFunc = cell(1,n); %#ok<MCSUP>
                This.LowerBounds = -inf(1,n); %#ok<MCSUP>
                This.UpperBounds = inf(1,n); %#ok<MCSUP>
            elseif is.numericscalar(List)
                n = List;
                This.ParamList = cell(1,n);
                for i = 1 : n
                    This.ParamList{i} = sprintf('p%g',i);
                end
            else
                utils.error('poster:set:ParamList', ...
                    'Invalid assignment to poster.paramList.');
            end
        end
        
        function This = set.InitParam(This,Init)
            n = length(This.ParamList); %#ok<MCSUP>
            if isnumeric(Init)
                Init = Init(:).';
                if length(Init) == n
                    This.InitParam = Init;
                    chkbounds(This);
                else
                    utils.error('poster:set:InitParam', ...
                        ['Length of the initial parameter vector ', ...
                        'must match the number of parameters.']);
                end
            else
                utils.error('poster:set:InitParam', ...
                    'Invalid assignment to poster.InitParam.');
            end
        end
        
        function This = set.LowerBounds(This,X)
            n = length(This.ParamList); %#ok<MCSUP>
            if numel(X) == n
                This.LowerBounds = -inf(1,n);
                This.LowerBounds(:) = X(:);
                chkbounds(This);
            else
                utils.error('poster:set:LowerBounds', ...
                    ['Length of lower bounds vector must match ', ...
                    'the number of parameters.']);
            end
        end
        
        function This = set.UpperBounds(This,X)
            n = length(This.ParamList); %#ok<MCSUP>
            if numel(X) == n
                This.UpperBounds = -inf(1,n);
                This.UpperBounds(:) = X(:);
                chkbounds(This);
            else
                utils.error('poster:set:UpperBounds', ...
                    ['Length of upper bounds vector must match ', ...
                    'the number of parameters.']);
            end
        end
        
        function This = set.InitProposalCov(This,C)
            if ~isnumeric(C)
                utils.error('poster:set:InitProposalCov', ...
                    'Invalid assignment to poster.InitProposalCov.');
            end
            n = length(This.ParamList); %#ok<MCSUP>
            C = C(:,:);
            if any(size(C) ~= n)
                utils.error('poster:set:InitProposalCov', ...
                    ['Size of the initial proposal covariance matrix ', ...
                    'must match the number of parameters.']);
            end
            C = (C+C.')/2;
            CDiag = diag(C);
            if ~all(CDiag > 0)
                utils.error('poster:set:InitProposalCov', ...
                    ['Diagonal elements of the initial proposal ', ...
                    'cov matrix must be positive.']);
            end
            ok = false;
            adjusted = false;
            offDiagIndex = eye(size(C)) == 0;
            count = 0;
            while ~ok && count < 100
                try
                    chol(C);
                    ok = true;
                catch %#ok<CTCH>
                    C(offDiagIndex) = 0.9*C(offDiagIndex);
                    C = (C+C.')/2;
                    adjusted = true;
                    ok = false;
                    count = count + 1;
                end
            end
            if ~ok
                utils.error('poster:set:InitProposalCov', ...
                    ['Cannot make the initial proposal cov matrix ', ...
                    'positive definite.']);
            elseif adjusted
                utils.warning('poster:set:InitProposalCov', ...
                    ['The initial proposal cov matrix ', ...
                    'adjusted to be numerically positive definite.']);
            end
            This.InitProposalCov = C;
        end
        
    end
    
    methods (Hidden) 
        
        function This = setlowerbounds(This,varargin)
            This = setbounds(This,'lower',varargin{:});
        end
        
        function This = setupperbounds(This,varargin)
            This = setbounds(This,'upper',varargin{:});
        end
        
        function This = setbounds(This,LowerUpper,varargin)
            if length(varargin) == 1 && isnumeric(varargin{1})
                if LowerUpper(1) == 'l'
                    This.LowerBounds = varargin{1};
                else
                    This.UpperBounds = varargin{1};
                end
            elseif length(varargin) == 2 ...
                    && (ischar(varargin{1}) || iscellstr(varargin{1})) ...
                    && isnumeric(varargin{2})
                userList = varargin{1};
                if ischar(userList)
                    userList = regexp(userList,'\w+','match');
                end
                userList = userList(:).';
                pos = nan(size(userList));
                for i = 1 : length(userList)
                    temp = find(strcmp(This.ParamList,userList{i}));
                    if ~isempty(temp)
                        pos(i) = temp;
                    end
                end
                if any(isnan(pos))
                    utils.error('poster:setbounds', ...
                        'This is not a valid parameter name: ''%s''.', ...
                        userList{isnan(pos)});
                end
                if LowerUpper(1) == 'l'
                    This.LowerBounds(pos) = varargin{2}(:).';
                else
                    This.UpperBounds(pos) = varargin{2}(:).';
                end
            end
            chkbounds(This);
        end
        
        function This = setprior(This,Name,Func)
            if ischar(Name) && is.func(Func)
                pos = strcmp(This.ParamList,Name);
                if any(pos)
                    This.LogPriorFunc{pos} = Func;
                else
                    utils.error('poster:setprior', ...
                        'This is not a valid parameter name: ''%s''.', ...
                        Name);
                end
            end
        end
        
        function chkbounds(This)
            n = length(This.ParamList);
            if isempty(This.InitParam)
                return
            end
            if isempty(This.LowerBounds)
                This.LowerBounds = -inf(1,n);
            end
            if isempty(This.UpperBounds)
                This.UpperBounds = inf(1,n);
            end
            inx = This.InitParam < This.LowerBounds ...
                | This.InitParam > This.UpperBounds;
            if any(inx)
                utils.error('poster:chkbounds', ...
                    ['The initial value for this parameter is ', ...
                    'out of bounds: ''%s''.'], ...
                    This.ParamList{inx});
            end
        end
        
    end
    
    methods (Access=protected, Hidden)
        varargout = mylogpost(varargin)
        varargout = mysimulate(varargin)
        varargout = mystruct2obj(varargin)
    end
    
    methods (Static,Hidden)
        varargout = loadobj(varargin)
        varargout = myksdensity(varargin)
    end
    
end