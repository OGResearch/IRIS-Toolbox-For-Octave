function This = set(This,varargin)
% set  [Not a public function]
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

pp = inputParser();
pp = pp.addRequired('This',@(x) isa(x,'neuron'));
pp = pp.addRequired('name',@iscellstr);
pp = pp.addRequired('value',@(x) length(x) == length(varargin(1:2:end-1)));
pp = pp.parse(This,varargin(1:2:end-1),varargin(2:2:end));

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
    utils.error('neuron', ...
        'This is not a modifiable neuron object property: ''%s''.', ...
        varargin{~found});
end

% Report values that do not pass validation.
if any(~validated)
    utils.error('neuron', ...
        'The value for this property does not pass validation: ''%s''.', ...
        varargin{~validated});
end

% Subfunctions.

%**************************************************************************
    function [Found,Validated] = doSet(UsrQuery,Value)
        
        Found = true;
        Validated = true;
        query = nnet.myalias(UsrQuery);
        
        if isfunc(Value) || isnumericscalar(Value)
            Value = @(x) Value() ;
            switch query
                case 'activation'
                    This.ActivationParams ...
                        = arrayfun( Value, This.ActivationParams ) ;
                
                case 'activationbounds'
                    This.ActivationBounds ...
                        = arrayfun( Value, This.ActivationBounds ) ;

                case 'output'
                    This.OutputParams ...
                        = arrayfun( Value, This.OutputParams ) ;

                case 'outputbounds'
                    This.OutputBounds ...
                        = arrayfun( Value, This.OutputBounds ) ;
                    
                case 'hyper'
                    This.HyperParams ...
                        = arrayfun( Value, This.HyperParams ) ;
                    
                case 'hyperbounds'
                    This.HyperBounds ...
                        = arrayfun( Value, This.HyperBounds ) ;
                    
                case 'bounds'
                    This.ActivationBounds ...
                        = arrayfun( Value, This.ActivationBounds ) ;
                    This.OutputBounds ...
                        = arrayfun( Value, This.OutputBounds ) ;
                    This.HyperBounds ...
                        = arrayfun( Value, This.HyperBounds ) ;
                    
                case 'userdata'
                    This = userdata(This,Value) ;
                    
                otherwise
                    Found = false ;
                    
            end
        else
            switch query
                case 'activation'
                    This.ActivationParams = Value ;
                    
                case 'activationbounds'
                    This.ActivationBounds = Value ;

                case 'output'
                    This.OutputParams = Value ;
                    
                case 'outputbounds'
                    This.OutputBounds = Value ;

                case 'params'
                    ns = This.nActivationParams ;
                    This.ActivationParams = Value(1:ns) ;
                    ne = This.nActivationParams+This.nHyperParams ;
                    This.HyperParams = Value(ns+1:ne) ;
                    This.OutputParams = Value(ne+1:end) ;
                    
                case 'bounds'
                    ns = This.nActivationParams ;
                    This.ActivationBounds = Value(1:ns) ;
                    ne = This.nActivationParams+This.nHyperParams ;
                    This.HyperBounds = Value(ns+1:ne) ;
                    This.OutputBounds = Value(ne+1:end) ;

                case 'hyper'
                    This.HyperParams = Value ;
                    
                otherwise
                    Found = false ;
                    
            end
        end
        
    end % doSet().

end