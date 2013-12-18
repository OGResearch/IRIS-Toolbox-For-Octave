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

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('This',@(x) isa(x,'nnet'));
pp.addRequired('name',@iscellstr);
pp.addRequired('value',@(x) length(x) == length(varargin(1:2:end-1)));
pp.parse(This,varargin(1:2:end-1),varargin(2:2:end));

%--------------------------------------------------------------------------

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
    utils.error('nnet', ...
        'This is not a modifiable neural network model object property: ''%s''.', ...
        varargin{~found});
end

% Report values that do not pass validation.
if any(~validated)
    utils.error('nnet', ...
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
                case 'activation'
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode} ...
                                = set( This.Neuron{iLayer}{iNode}, 'activation', Value ) ;
                        end
                    end
                    
                case 'activationbounds'
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode} ...
                                = set( This.Neuron{iLayer}{iNode}, 'activationbounds', Value ) ;
                        end
                    end
                    
                case 'output'
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode} ...
                                = set( This.Neuron{iLayer}{iNode}, 'output', Value ) ;
                        end
                    end
                    
                case 'outputbounds'
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode} ...
                                = set( This.Neuron{iLayer}{iNode}, 'outputbounds', Value ) ;
                        end
                    end
                    
                case 'hyper'
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode} ...
                                = set( This.Neuron{iLayer}{iNode}, 'hyper', Value ) ;
                        end
                    end
                    
                case 'hyperbounds'
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode} ...
                                = set( This.Neuron{iLayer}{iNode}, 'hyperbounds', Value ) ;
                        end
                    end
                    
                case 'bounds'
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode} ...
                                = set( This.Neuron{iLayer}{iNode}, 'bounds', Value ) ;
                        end
                    end
                    
                case 'param'
                    This = set( This, 'activation', Value ) ;
                    This = set( This, 'output', Value ) ;
                    This = set( This, 'hyper', Value ) ;

                case 'userdata'
                    This = userdata( This, Value );
                    
                otherwise
                    Found = false;
                    
            end
        else
            % Value is a vector
            switch query
                case 'activation'
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode}.ActivationParams ...
                                = Value( This.Neuron{iLayer}{iNode}.ActivationIndex ) ;
                        end
                    end
                    
                case 'activationBounds'
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode}.ActivationBounds ...
                                = Value( This.Neuron{iLayer}{iNode}.ActivationIndex ) ;
                        end
                    end
                    
                case 'output'
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode}.OutputParams ...
                                = Value( This.Neuron{iLayer}{iNode}.OutputIndex ) ;
                        end
                    end
                    
                case 'outputBounds'
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode}.OutputBounds ...
                                = Value( This.Neuron{iLayer}{iNode}.OutputIndex ) ;
                        end
                    end
                    
                case 'hyper'
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode}.HyperParams ...
                                = Value( This.Neuron{iLayer}{iNode}.HyperIndex ) ;
                        end
                    end
                    
                case 'hyperBounds'
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode}.HyperBounds ...
                                = Value( This.Neuron{iLayer}{iNode}.HyperIndex ) ;
                        end
                    end
                    
                case 'param'
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode}.ActivationParams ...
                                = Value( This.Neuron{iLayer}{iNode}.ActivationIndex ) ;
                        end
                    end
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode}.HyperParams ...
                                = Value( This.nActivationParams+This.Neuron{iLayer}{iNode}.HyperIndex ) ;
                        end
                    end
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode}.OutputParams ...
                                = Value( This.nActivationParams+This.nHyperParams+This.Neuron{iLayer}{iNode}.OutputIndex ) ;
                        end
                    end

                case 'bounds'
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode}.ActivationBounds ...
                                = Value( This.Neuron{iLayer}{iNode}.ActivationIndex ) ;
                        end
                    end
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode}.HyperBounds ...
                                = Value( This.nActivationParams+This.Neuron{iLayer}{iNode}.HyperIndex ) ;
                        end
                    end
                    for iLayer = 1:This.nLayer+1
                        for iNode = 1:numel(This.Neuron{iLayer})
                            This.Neuron{iLayer}{iNode}.OutputBounds ...
                                = Value( This.nActivationParams+This.nHyperParams+This.Neuron{iLayer}{iNode}.OutputIndex ) ;
                        end
                    end
                    
                otherwise
                    Found = false ;
                    
            end
        end
        
    end % doSet().

end