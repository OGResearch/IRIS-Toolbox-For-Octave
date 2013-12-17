function Dou = eval(This,Din)
% eval  [Not a public function]
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

switch This.ActivationFn
    case 'bias'
        Dou = 1 ;
    otherwise
        Dou = xxOutput(xxActivation(Din)) ;
end

    function out = xxActivation(in)
        switch This.ActivationFn
            case 'linear'
                out = This.ActivationParams'*in ;
            case 'minkovsky'
                out = norm(in-This.ActivationParams,This.HyperParams) ;
        end
    end

    function out = xxOutput(in)
        switch This.OutputFn
            case 's4'
                out = (This.OutputParams.*in)./sqrt(1+This.OutputParams.^2*in.^2) ;
            case 'logistic'
                out = 1./(1-exp(in)) ;
            case 'tanh'
                atmp = exp(-in*This.OutputParams) ;
                out = (1-atmp)/(1+atmp) ;
        end
    end
end



