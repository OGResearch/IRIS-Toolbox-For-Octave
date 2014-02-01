function disp(This)

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.


if ~isempty(This)
    
    fprintf(1,'\tneural network model object:\n') ;
    
    % Inputs
    fprintf(1,'\t[%g] inputs: ',This.nInputs) ;
    fprintf(1,'%s',This.Inputs{1}) ;
    for ii=2:numel(This.Inputs)
        fprintf(1,', %s',This.Inputs{ii}) ;
    end
    fprintf('\n') ;
    
    % Hidden Layer
    fprintf(1,'\t[%g] layout: \n',This.nLayer) ;
    for ii=1:This.nLayer
        fprintf(1,'\t\tlayer %g: %s activation, %s output, %g nodes',...
            ii, This.ActivationFn{ii},This.OutputFn{ii}, This.Layout(ii)) ;
        if This.Bias(ii)
            fprintf(1,' + bias\n') ;
        else
            fprintf(1,'\n') ;
        end
    end
    fprintf(1,'\t\toutput layer: %s activation, %s output\n',...
        This.ActivationFn{This.nLayer+1},This.OutputFn{This.nLayer+1}) ;
    
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






