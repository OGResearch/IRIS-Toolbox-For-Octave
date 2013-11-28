function This = set(This,varargin)
% set  Change modifiable nnet object property.
%
% Syntax
% =======
%
%     M = set(M,Request,Value)
%     M = set(M,Request,Value,Request,Value,...)
%
% Input arguments
% ================
%
% * `M` [ nnet ] - Neural network model object.
%
% * `Request` [ char ] - Name of a modifiable neural network model object
% property that will be changed.
%
% * `Value` [ ... ] - Value to which the property will be set.
%
% Output arguments
% =================
%
% * `M` [ nnet ] - Neural network model object with the requested
% property or properties modified.
%
% Valid requests to neural network model objects
% ===============================================
%
% Equation labels and aliases
% ----------------------------
%
% * `'weight='`, `'bias='`, `'transfer='` [ numeric | function_handle ]
% - Change values of different classes of parameters.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('This',@(x) isa(x,'nnet'));
pp.addRequired('name',@iscellstr);
pp.addRequired('value',@(x) length(x) == length(varargin(1:2:end-1)));
pp.parse(This,varargin(1:2:end-1),varargin(2:2:end));

%--------------------------------------------------------------------------

% If Params doesn't exist, create it (relevant for @nnet constructor)
if isempty(This.Params)
    This.Params ...
        = cellfun(@(x) struct(), cell(This.nLayer+2,1), 'UniformOutput', false) ;
    
    % No weighting possible at input nodes
    This.Params{1}.Bias ...
        = cellfun(any2func(NaN), cell(This.nInputs,1), 'UniformOutput', false) ;
    This.Params{1}.Transfer ...
        = cellfun(any2func(NaN), cell(This.nInputs,1), 'UniformOutput', false) ;
    
    % First nodes weight inputs
    This.Params{2}.Weight ...
        = cellfun(any2func(NaN(This.nInputs,1)), cell(This.HiddenLayout(1),1), 'UniformOutput', false) ;
    This.Params{2}.Bias ...
        = cellfun(any2func(NaN), cell(This.HiddenLayout(1),1), 'UniformOutput', false) ;
    This.Params{2}.Transfer ...
        = cellfun(any2func(NaN), cell(This.HiddenLayout(1),1), 'UniformOutput', false) ;
    
    % Subsequent nodes weight outputs of previous layer
    for iLayer = 2:This.nLayer
        This.Params{iLayer+1}.Weight ...
            = cellfun(any2func(NaN(This.HiddenLayout(iLayer-1),1)), cell(This.HiddenLayout(iLayer),1), 'UniformOutput', false) ;
        This.Params{iLayer+1}.Bias ...
            = cellfun(any2func(NaN), cell(This.HiddenLayout(iLayer),1), 'UniformOutput', false) ;
        This.Params{iLayer+1}.Transfer ...
            = cellfun(any2func(NaN), cell(This.HiddenLayout(iLayer),1), 'UniformOutput', false) ;
    end
    
    % Output nodes weight outputs of last layer
    This.Params{end}.Weight ...
        = cellfun(any2func(NaN(This.HiddenLayout(end),1)), cell(This.nOutputs,1), 'UniformOutput', false) ;
    This.Params{end}.Bias ...
        = cellfun(any2func(NaN), cell(This.nOutputs,1), 'UniformOutput', false) ;
    This.Params{end}.Transfer ...
        = cellfun(any2func(NaN), cell(This.nOutputs,1), 'UniformOutput', false) ;
end

% Body
varargin(1:2:end-1) = strtrim(varargin(1:2:end-1));
nArg = length(varargin);
found = true(1,nArg);
validated = true(1,nArg);
for iArg = 1 : 2 : nArg
    [found(iArg),validated(iArg)] = ...
        doSet(lower(varargin{iArg}),varargin{iArg+1});
end

% Report queries that are not modifiable model object properties.
if any(~found)
    utils.error('model', ...
        'This is not a modifiable model object property: ''%s''.', ...
        varargin{~found});
end

% Report values that do not pass validation.
if any(~validated)
    utils.error('model', ...
        'The value for this property does not pass validation: ''%s''.', ...
        varargin{~validated});
end

% Subfunctions.

%**************************************************************************
    function [Found,Validated,iLayer] = doSet(UsrQuery,Value)
        
        Found = true;
        Validated = true;
        query = nnet.myalias(UsrQuery);
        
        if isfunc(Value) || isnumericscalar(Value)
            switch query
                
                case 'weight'
                    Value = any2func(Value) ;
                    for iLayer = 1:This.nLayer+2
                        if iLayer>1
                            for iNode = 1:numel(This.Params{iLayer}.Weight)
                                for iInput = 1:numel(This.Params{iLayer}.Weight{iNode})
                                    This.Params{iLayer}.Weight{iNode}(iInput) = Value() ;
                                end
                            end
                        end
                    end
                    
                case 'bias'
                    Value = any2func(Value) ;
                    for iLayer = 1:This.nLayer+2
                        for iNode = 1:numel(This.Params{iLayer}.Bias)
                            This.Params{iLayer}.Bias{iNode} = Value() ;
                        end
                    end
                    
                case 'transfer'
                    Value = any2func(Value) ;
                    for iLayer = 1:This.nLayer+2
                        for iNode = 1:numel(This.Params{iLayer}.Transfer)
                            This.Params{iLayer}.Transfer{iNode} = Value() ;
                        end
                    end
                    
                case 'param'
                    Value = any2func(Value) ;
                    This = set(This,'weight',Value) ;
                    This = set(This,'bias',Value) ;
                    This = set(This,'transfer',Value) ;
                    
                case 'userdata'
                    This = userdata(This,Value);
                    
                otherwise
                    Found = false;
                    
            end
        else
            % Value is a vector
            Xcount = 0 ;
            switch query
                case 'bias'
                    if This.nBias == numel(Value)
                        for iLayer = 1:This.nLayer+2
                            for iNode = 1:numel(This.Params{iLayer}.Bias)
                                Xcount = Xcount + 1 ;
                                This.Params{iLayer}.Bias{iNode} = Value(Xcount) ;
                            end
                        end
                    else
                        utils.error('nnet:set',...
                            'Dimension mismatch.') ;
                    end
                    
                case 'transfer'
                    if This.nTransfer == numel(Value)
                        for iLayer = 1:This.nLayer+2
                            for iNode = 1:numel(This.Params{iLayer}.Transfer)
                                Xcount = Xcount + 1 ;
                                This.Params{iLayer}.Transfer{iNode} = Value(Xcount) ;
                            end
                        end
                    else
                        utils.error('nnet:set',...
                            'Dimension mismatch.') ;
                    end
                    
                case 'weight'
                    if This.nWeight == numel(Value)
                        for iLayer = 1:This.nLayer+2
                            if iLayer>1
                                for iNode = 1:numel(This.Params{iLayer}.Weight)
                                    for iInput = 1:numel(This.Params{iLayer}.Weight{iNode})
                                        Xcount = Xcount + 1 ;
                                        This.Params{iLayer}.Weight{iNode}(iInput) = Value(Xcount) ;
                                    end
                                end
                            end
                        end
                    else
                        utils.error('nnet:set',...
                            'Dimension mismatch.') ;
                    end
                    
                otherwise
                    Found = false ;
                    
            end
        end
        
    end % doSet().

    function fh = any2func(in)
        if isfunc(in)
            fh = in ;
        else
            fh = @(x) in ;
        end
    end

end