function That = copy(This)
% copy  [Not a public function]
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

That = neuron(This.ActivationFn,...
    This.OutputFn,...
    numel(This.ActivationParams),...
    This.Position,...
    This.ActivationIndex,...
    This.OutputIndex,...
    This.HyperIndex) ;

MC = metaclass(This) ;
for iProp = 1:numel(MC.PropertyList)
    if ~any(strcmpi(MC.PropertyList(iProp).Name,{'ForwardConnection','BackwardConnection'}))
        That.(MC.PropertyList(iProp).Name) ...
            = This.(MC.PropertyList(iProp).Name) ;
    end
end

end


