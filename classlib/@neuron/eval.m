function [Dou,Dou2] = eval(This,Din)
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
        if nargout>1
            tmp2 = xxActivation(Din) ;
            [Dou,tmp3] = xxOutput(tmp2) ;
            Dou2 = tmp2.*tmp3 ;
        else
            Dou = xxOutput(xxActivation(Din)) ;            
        end
end

    function [out,out2] = xxActivation(in)
        switch This.ActivationFn
            case 'linear'
                out = in*This.ActivationParams ;
                if nargout>1
                    out2 = in ;
                end
            case 'minkovsky'
                tmp = bsxfun(@minus,in,This.ActivationParams') ;
                tmp = bsxfun(@power,tmp,This.HyperParams) ;
                tmp = sum(tmp,2) ;
                out = bsxfun(@power,tmp,1/This.HyperParams) ;
        end
    end

    function [out,out2] = xxOutput(in)
        switch This.OutputFn
            case 's4'
                out = (This.OutputParams.*in)./sqrt(1+This.OutputParams.^2*in.^2) ;
                if nargout>1
                    out2 = -This.OutputParams^3*in.^2/(1+in.^2)^(3/2) ...
                        + This.OutputParams/sqrt(1+in.^2) ;
                end
            case 'logistic'
                out = 1./(1+exp(-This.OutputParams.*in)) ;
            case 'tanh'
                atmp = exp(-in*This.OutputParams) ;
                out = (1-atmp)/(1+atmp) ;
        end
    end
end



