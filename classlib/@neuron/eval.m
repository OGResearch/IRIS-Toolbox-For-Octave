function [Dou,Dou2,Dou3] = eval(This,Din)
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
            [tmp2,tmp4,tmp5] = xxActivation(Din) ;
            [Dou,tmp3] = xxOutput(tmp2) ;
            Dou2 = (tmp4.^2).*tmp3 ;
            Dou3 = bsxfun(@times,tmp5.^2,tmp3) ;
        else
            Dou = xxOutput(xxActivation(Din)) ;            
        end
end

    function [out,out2,out3] = xxActivation(in)
        % Second argument is the first derivative w.r.t the activation
        % (typically weight) parameters
        % 
        % Third argument is the first derivative w.r.t. the input
        T = length(in) ;
        switch This.ActivationFn
            case 'linear'
                out = in*This.ActivationParams(:) ;
                if nargout>1
                    out2 = in ;
                    out3 = repmat( This.ActivationParams(:)', T, 1 ) ;
                end
            case 'minkovsky'
                tmp = bsxfun(@minus,in,This.ActivationParams') ;
                tmp = bsxfun(@power,tmp,This.HyperParams) ;
                tmp = sum(tmp,2) ;
                out = bsxfun(@power,tmp,1/This.HyperParams) ;
        end
    end

    function [out,out2] = xxOutput(in)
        % Second argument is the second derivative w.r.t. the input 
        switch This.OutputFn
            case 's4'
                out = (This.OutputParams.*in)./sqrt(1+This.OutputParams.^2*in.^2) ;
                if nargout>1
                    out2 = -(3*This.OutputParams^3*in)./(This.OutputParams^2*in.^2+1)^5/2 ;
                end
            case 'logistic'
                out = 1./(1+exp(-This.OutputParams.*in)) ;
                if nargout>1
                    tmp = exp(This.OutputParams*in) ;
                    out2 = -(2*This.OutputParams^2*tmp.*(tmp-1))./(tmp+1).^3 ;
                end
            case 'tanh'
                atmp = exp(-in*This.OutputParams) ;
                out = (1-atmp)/(1+atmp) ;
                if nargout>1
                    tmp = exp(This.OutputParams*in) ;
                    out2 = -(2*This.OutputParams^2*tmp.*(tmp-1))./(tmp+1).^3 ;
                end
        end
    end
end



