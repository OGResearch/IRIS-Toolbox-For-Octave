classdef progressbar < handle
    % progressbar  [Not a public class] Display progress bar in the command window.
    
    properties
        title = '';
        nProgress = 40;
        nBar = 0;
        display = '*';
    end
    
    methods
        
        function This = progressbar(varargin)
            if nargin > 0
                This.title = varargin{1};
            end
            x = '-';
            screen = ['[',x(ones(1,This.nProgress)),']'];
            if ~isempty(This.title)
                This.title = This.title(1:min(end,This.nProgress-4));
                screen(3+(1:length(This.title))) = This.title;
            end
            strfun.loosespace();
            disp(screen);
            fprintf('[]');
        end
        
        function This = update(This,N)
            x = This.nBar;
            This.nBar = round(This.nProgress*N);
            if This.nBar > x
                c = This.display(1);
                fprintf('\b');
                fprintf(c(ones(1,This.nBar-x)));
                fprintf(']');
                if This.nBar >= This.nProgress
                    fprintf('\n');
                    strfun.loosespace();
                end
            end
        end
        
    end
    
end