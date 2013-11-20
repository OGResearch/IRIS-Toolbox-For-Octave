function disp(This) 

fprintf(1,'\t%s neural network model object: [%g] parameterisation(s)\n', ...
    This.Type, This.nAlt) ;

% Inputs
fprintf(1,'\tinputs (with %s transfer function): ',This.InputTransfer) ;
fprintf(1,'%s',This.Inputs{1}) ;
for ii=2:numel(This.Inputs)
    fprintf(1,', %s',This.Inputs{ii}) ;
end
fprintf('\n') ;

% Hidden Layer
nLayers = numel(This.HiddenTransfer) ;
fprintf(1,'\thidden layers: [%g]\n',nLayers) ;
for ii=1:nLayers
    fprintf(1,'\t\tlayer %g: %s transfer, %g nodes\n',...
        ii, This.HiddenTransfer{ii}, This.HiddenLayout(ii)) ;
end

% Outputs
fprintf(1,'\toutputs (with %s transfer function): ',This.OutputTransfer) ;
fprintf(1,'%s',This.Outputs{1}) ;
for ii=2:numel(This.Outputs)
    fprintf(1,'%s, ',This.Outputs{ii}) ;
end
fprintf('\n') ;

end






