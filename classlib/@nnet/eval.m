function [OutData] = eval(This,InData,Range,varargin)

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if nargin<3
    Range = Inf ;
end
if ischar(Range)
    varargin = [Range, varargin] ;
    Range = Inf ;
end
pp = inputParser() ;
pp.addRequired('This',@(x) isa(x,'nnet')) ;
pp.addRequired('Data',@(x) isa(x,'tseries') || isa(x,'struct')) ;
pp.addOptional('Range',@(x) isnumeric(x) && isvector(x)) ;
pp.parse(This,InData,Range) ;
if This.nAlt>1
    utils.error('nnet:eval',...
        'Eval does not support input neural network objects with multiple parameterizations.') ;
end
if isinf(Range)
    if isstruct(InData)
        Var = cellfun(@(x) x{1}, ...
            regexp(This.Inputs,'\{[-\+]?\d*}','split'), ...
            'UniformOutput', false) ;
        Range = dbrange(InData,Var) ;
    else
        Range = range(InData) ;
    end
end

% Parse options
options = passvalopt('nnet.eval',varargin{:}) ;

% Handle data
if isstruct(InData)
    [InData] = datarequest('Inputs',This,InData,Range) ;
end
if options.Ahead>1 && This.nOutputs>1
    options.Output = 'dbase' ;
end

% Body
switch options.Output
    case 'tseries'
        OutData = tseries() ;
    case 'dbase'
        OutData = struct() ;
        for iOutput = 1:This.nOutputs
            OutData.(This.Outputs{iOutput}) = tseries() ;
        end
end
if options.Ahead>1
    kPred = InData ;
    for k = 1:options.Ahead
        kPred = eval(This,kPred,Range) ;
        switch options.Output
            case 'dbase'
                for iOutput = 1:This.nOutputs
                    OutData.(This.Outputs{iOutput})(Range+k-1,k) = kPred(:,iOutput) ;
                end
            case 'tseries'
                % only one output if output is tseries and ahead>1
                OutData(Range+k-1,k) = kPred(:) ;
        end
    end
else
    switch This.Type
        case 'feedforward'
            % Input Layer
            iLayer = 0 ;
            InLayer = tseries() ;
            for iInput = 1:This.nInputs
                InLayer(Range,iInput) ...
                    = xxNodeTransfer(...
                    InData{Range,iInput}, ...
                    1.0, ...
                    This.Params{1}.Bias{iInput}, ...
                    This.InputTransfer, ...
                    This.Params{1}.Transfer{iInput} ...
                    ) ;
            end
            
            % Hidden Layers
            for iLayer = 1:This.nLayer
                OutLayer = tseries(Range, NaN(length(Range),This.HiddenLayout(iLayer))) ;
                for iNode = 1:This.HiddenLayout(iLayer)
                    OutLayer(Range,iNode) ...
                        = xxNodeTransfer(...
                        InLayer{Range,:}, ...
                        This.Params{iLayer+1}.Weight{iNode},...
                        This.Params{iLayer+1}.Bias{iInput}, ...
                        This.HiddenTransfer{iLayer}, ...
                        This.Params{iLayer+1}.Transfer{iNode} ...
                        ) ;
                end
                InLayer = OutLayer ;
            end
            
            % Output Layers
            % (iNode is iOutput) 
            for iNode = 1:This.nOutputs
                iLayer = iLayer + 1 ;
                tmpOut = xxNodeTransfer(...
                    OutLayer{Range,:}, ...
                    This.Params{end}.Weight{iNode}, ...
                    This.Params{end}.Bias{iNode}, ...
                    This.OutputTransfer, ...
                    This.Params{end}.Transfer{iNode} ...
                    ) ;
                switch options.Output
                    case 'dbase'
                        OutData.(This.Outputs{iNode}) = tmpOut ;
                    case 'tseries'
                        OutData(Range,iNode) ...
                            = tmpOut ;
                end
            end
            
        otherwise
            utils.error('nnet:objfunc',...
                'Unsupported neural network type.') ;
    end
end

    function Output = xxNodeTransfer(Input, Weight, Bias, Transfer, TransferParam)
        switch Transfer
            case 'sigmoid'
                X = ( 1./(1-exp(-Input.*TransferParam)) ) ;
                Output = Bias + sum(Weight'.*X,2) ;
            case 'softmax'
                Output = Input(:,iNode) ./ sum(Weight'.*Input,2) ;
            case 'tanh'
                X = ( 1-exp(-TransferParam.*Input) )./( 1+exp(-TransferParam.*Input) ) ;
                Output = Bias + sum(Weight'.*X,2) ;
            case 'step'
                X = ( Input>0 ) ;
                Output = Bias + sum(Weight'.*X,2) ;
            case 'linear'
                X = Input ;
                Output = Bias + sum(Weight'.*X,2) ;
        end
        
        
        
        if isempty(Output)
            % Must be NaN values
            Output = tseries(Range,1e+10*ones(1,This.nOutputs)) ;
            if iLayer == 0
                msg = 'NaN values in input layer.\n' ;
            elseif iLayer>This.nLayer
                msg = 'NaN values in output layer.\n' ;
            else
                msg = 'NaN values in layer [%g].\n' ;
            end
            utils.warning('nnet:eval',...
                msg,iLayer+1) ;
        end
    end

end

