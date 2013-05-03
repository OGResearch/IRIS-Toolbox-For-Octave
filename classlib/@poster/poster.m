classdef poster
% poster  Posterior objects and functions.
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
% * [`poster`](poster/poster) - Posterior objects and functions.
%
% Evaluating posterior density
% =============================
%
% * [`arwm`](poster/arwm) - Adaptive random-walk Metropolis posterior simulator.
% * [`eval`](poster/eval) - Evaluate posterior density at specified points.
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
% -Copyright (c) 2007-2013 IRIS Solutions Team.

    properties
        paramList = {};
        minusLogPostFunc = [];
        minusLogPostFuncArgs = {};
        minusLogLikFunc = [];
        minusLogLikFuncArgs = {};
        logPriorFunc = {};
        initLogPost = NaN;
        initParam = [];
        initProposalCov = [];
        lowerBounds = [];
        upperBounds = [];
    end
    
    methods
        
        function This = poster(varargin)
            if isempty(varargin)
                return
            elseif length(varargin) == 1 && isa(varargin{1},'poster')
                This = varargin{1};
            end
        end
        
        varargout = arwm(varargin)
        varargout = eval(varargin)
        varargout = stats(varargin)
        
        function This = set.paramList(This,List)
            if ischar(List) || iscellstr(List)
                if ischar(List)
                    List = regexp(List,'\w+','match');
                end
                This.paramList = List(:).';
                if length(This.paramList) ~= length(unique(This.paramList))
                    utils.error('poster', ...
                        'Parameter names must be unique.');
                end
                n = length(This.paramList);
                This.logPriorFunc = cell([1,n]); %#ok<MCSUP>
                This.lowerBounds = -inf([1,n]); %#ok<MCSUP>
                This.upperBounds = inf([1,n]); %#ok<MCSUP>
            elseif isnumericscalar(List)
                n = List;
                This.paramList = cell([1,n]);
                for i = 1 : n
                    This.paramList{i} = sprintf('p%g',i);
                end
            else
                utils.error('poster', ...
                    'Invalid assignment to poster.paramList.');
            end
        end
        
        function This = set.initParam(This,Init)
            n = length(This.paramList); %#ok<MCSUP>
            if isnumeric(Init)
                Init = Init(:).';
                if length(Init) == n
                    This.initParam = Init;
                    chkbounds(This);
                else
                    utils.error('poster', ...
                        ['Length of the initial parameter vector ', ...
                        'must match the number of parameters.']);
                end
            else
                utils.error('poster', ...
                    'Invalid assignment to poster.initParam.');
            end
        end
        
        function This = set.lowerBounds(This,X)
            n = length(This.paramList); %#ok<MCSUP>
            if numel(X) == n
                This.lowerBounds = -inf([1,n]);
                This.lowerBounds(:) = X(:);
                chkbounds(This);
            else
                utils.error('poster', ...
                    ['Length of lower bounds vector must match ', ...
                    'the number of parameters.']);
            end
        end
        
        function This = set.upperBounds(This,X)
            n = length(This.paramList); %#ok<MCSUP>
            if numel(X) == n
                This.upperBounds = -inf([1,n]);
                This.upperBounds(:) = X(:);
                chkbounds(This);
            else
                utils.error('poster', ...
                    ['Length of upper bounds vector must match ', ...
                    'the number of parameters.']);
            end
        end
        
        function This = set.initProposalCov(This,C)
            if ~isnumeric(C)
                utils.error('poster', ...
                    'Invalid assignment to poster.initProposalCov.');
            end
            n = length(This.paramList); %#ok<MCSUP>
            C = C(:,:);
            if any(size(C) ~= n)
                utils.error('poster', ...
                    ['Size of the initial proposal covariance matrix ', ...
                    'must match the number of parameters.']);
            end
            C = (C+C.')/2;
            CDiag = diag(C);
            if ~all(CDiag > 0)
                utils.error('poster', ...
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
                utils.error('poster', ...
                    ['Cannot make the initial proposal cov matrix ', ...
                    'positive definite.']);
            elseif adjusted
                utils.warning('poster', ...
                    ['The initial proposal cov matrix ', ...
                    'adjusted to be numerically positive definite.']);
            end
            This.initProposalCov = C;
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
                    This.lowerBounds = varargin{1};
                else
                    This.upperBounds = varargin{1};
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
                    temp = find(strcmp(This.paramList,userList{i}));
                    if ~isempty(temp)
                        pos(i) = temp;
                    end
                end
                if any(isnan(pos))
                    utils.error('poster', ...
                        'This is not a valid parameter name: ''%s''.', ...
                        userList{isnan(pos)});
                end
                if LowerUpper(1) == 'l'
                    This.lowerBounds(pos) = varargin{2}(:).';
                else
                    This.upperBounds(pos) = varargin{2}(:).';
                end
            end
            chkbounds(This);
        end
        
        function This = setprior(This,Name,Func)
            if ischar(Name) && isa(Func,'function_handle')
                pos = strcmp(This.paramList,Name);
                if any(pos)
                    This.logPriorFunc{pos} = Func;
                else
                    utils.error('poster', ...
                        'This is not a valid parameter name: ''%s''.', ...
                        Name);
                end
            end
        end
        
        function chkbounds(This)
            n = length(This.paramList);
            if isempty(This.initParam)
                return
            end
            if isempty(This.lowerBounds)
                This.lowerBounds = -inf([1,n]);
            end
            if isempty(This.upperBounds)
                This.upperBounds = inf([1,n]);
            end
            inx = This.initParam < This.lowerBounds ...
                | This.initParam > This.upperBounds;
            if any(inx)
                utils.error('poster', ...
                    ['The initial value for this parameter is ', ...
                    'out of bounds: ''%s''.'], ...
                    This.paramList{inx});
            end
        end
        
    end
    
    methods (Access=protected, Hidden)
        varargout = mysimulate(varargin)
        varargout = mylogpost(varargin)
    end
    
    methods (Static,Hidden)
        varargout = myksdensity(varargin)
    end
    
end