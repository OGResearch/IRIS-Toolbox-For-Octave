function Obj = objfunc(This,Data,Range,Est,varargin)
% OBJFUNC  [Not a public function] Objective function value.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.
    
%**************************************************************************

nLayer = size(This.Params,1) ;
switch This.Type
    case 'feedforward'
        % Input Layer
        
        % Hidden Layers
        
        % Output Layers
        
    otherwise
        utils.error('nnet:objfunc',...
            'Unsupported neural network type.') ;
end

disp() ;

end
