function disp(This)

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.


if ~isempty(This)
    
    fprintf(1,'\tneural network model object: [%g] parameterisation(s)\n', This.nAlt) ;
    
    % Inputs
    fprintf(1,'\t[%g] inputs: ',This.nInputs) ;
    fprintf(1,'%s',This.Inputs{1}) ;
    for ii=2:numel(This.Inputs)
        fprintf(1,', %s',This.Inputs{ii}) ;
    end
    fprintf('\n') ;
    
    % Hidden Layer
    nLayers = numel(This.ActivationFn) ;
    fprintf(1,'\t[%g] hidden layers: \n',nLayers) ;
    for ii=1:nLayers
        fprintf(1,'\t\tlayer %g: %s activation, %s output, %g nodes',...
            ii, This.ActivationFn{ii},This.OutputFn{ii}, This.Layout(ii)) ;
        if This.Bias(ii)
            fprintf(1,' + bias\n') ;
        else
            fprintf(1,'\n') ;
        end
    end
    
    % Outputs
    fprintf(1,'\t[%g] outputs: ',This.nOutputs) ;
    fprintf(1,'%s',This.Outputs{1}) ;
    for ii=2:numel(This.Outputs)
        fprintf(1,', %s',This.Outputs{ii}) ;
    end
    fprintf('\n\n') ;
    
    % Comments
    disp@userdataobj(This) ;
end

end






