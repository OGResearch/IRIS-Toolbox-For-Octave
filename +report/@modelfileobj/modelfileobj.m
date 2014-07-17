classdef modelfileobj < report.userinputobj
    
    properties
        filename = '';
        modelobj = [];
    end
    
    methods
        
        function This = modelfileobj(varargin)
            This = This@report.userinputobj(varargin{:});
            This.childof = {'report'};
            This.default = [This.default,{ ...
                'latexalias',false,@islogicalscalar,false, ...
                'linenumbers',true,@islogicalscalar,true, ...
                'lines',Inf,@isnumeric,true, ...
                'paramvalues',true,@islogicalscalar,true, ....
                'separator','',@ischar,false, ...
                'syntax',true,@islogicalscalar,true, ...
                'typeface','',@ischar,false, ...
                }];
        end
        
        function [This,varargin] = specargin(This,varargin)
            if ~isempty(varargin) && ischar(varargin{1})
                This.filename = varargin{1};
                varargin(1) = [];
            end
            if ~isempty(varargin) && isa(varargin{1},'model')
                This.modelobj = varargin{1};
                varargin(1) = [];
            end
        end
        
    end
    
    methods (Access=protected,Hidden)

        varargout = printmodelfile(varargin)
        varargout = speclatexcode(varargin)
        
    end
    
end
