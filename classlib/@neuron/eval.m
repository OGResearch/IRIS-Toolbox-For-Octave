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
        T = length(in) ;
        switch This.ActivationFn
            case 'linear'
                out = in*This.ActivationParams(:) ;
            case 'minkovsky'
                tmp = bsxfun(@minus,in,This.ActivationParams(:)') ;
                tmp = bsxfun(@power,tmp,This.HyperParams) ;
                tmp = sum(tmp,2) ;
                out = bsxfun(@power,tmp,1/This.HyperParams) ;
        end
    end

    function out = xxOutput(in)
        % Second argument is the second derivative w.r.t. the input
        switch This.OutputFn
            case 's4'
                out = (This.OutputParams.*in)./sqrt(1+This.OutputParams.^2*in.^2) ;
            case 'logistic'
                out = 1./(1+exp(-This.OutputParams.*in)) ;
            case 'tanh'
                atmp = exp(-in*This.OutputParams) ;
                out = (1-atmp)/(1+atmp) ;
        end
    end
end



