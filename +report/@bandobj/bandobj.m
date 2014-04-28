classdef bandobj < report.seriesobj
    
    properties
        low = [];
        high = [];
    end
    
    methods
        
        function This = bandobj(varargin)
            This = This@report.seriesobj(varargin{:});
            This.default = [This.default,{ ...
                'bandformat',[],@(x) isempty(x) || ischar(x),false, ...
                'bandtypeface','\footnotesize',@ischar,true, ...
                'low','Low',@ischar,true, ...
                'high','High',@ischar,true, ...
                'relative',true,@is.logicalscalar,true, ...
                'white',0.8, ...
                @(x) isnumeric(x) && all(x >= 0) && all(x <= 1), ...
                true, ...
                'plottype','patch', ...
                @(x) any(strcmpi(x,{'errorbar','line','patch'})), ...
                true, ...
                }];
        end
        
        function [This,varargin] = specargin(This,varargin)
            [This,varargin] = specargin@report.seriesobj(This,varargin{:});
            if ~isempty(varargin)
                This.low = varargin{1};
                if isa(This.low,'tseries')
                    This.low = {This.low};
                end
                varargin(1) = [];
            end
            if ~isempty(varargin)
                This.high = varargin{1};
                if isa(This.high,'tseries')
                    This.high = {This.high};
                end
                varargin(1) = [];
            end
        end
        
        function This = setoptions(This,varargin)
            This = setoptions@report.seriesobj(This,varargin{:});
            if ischar(This.options.bandformat)
                utils.warning('report', ...
                    ['The option ''bandformat'' in report/band is obsolete ', ...
                    'and will be removed from future IRIS versions. ', ...
                    'Use ''bandtypeface'' instead.']);
                This.options.bandtypeface = This.options.bandformat;
            end
            % Check consistency of `Low` and `High` relative to `X`. This function
            % needs to be finished.
            chkconsistency(This);
        end
        
        varargout = latexonerow(varargin)
        varargout = plot(varargin)
        varargout = chkconsistency(varargin)
        
    end
    
    methods (Access=protected,Hidden)
        varargout = speclatexcode(varargin)
    end
        
end