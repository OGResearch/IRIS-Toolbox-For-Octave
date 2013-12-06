classdef likfunc < estimateobj & getsetobj & userdataobj
   
    properties
        form = '';
        userFunc = [];
        minusLogLikFunc = [];
        name = cell(1,0);
        nameType = zeros(1,0);
    end
    
    methods
       
        function This = likfunc(varargin)
            This = This@getsetobj();
            This = This@userdataobj();
            
            if isempty(varargin)
                return
            end
            if length(varargin) == 1 && isa(varargin{1},'likfunc')
                This = varargin{1};
                return
            end
            if length(varargin) >= 3 ...
                    && ischar(varargin{1})...
                    && (iscellstr(varargin{2}) || ischar(varargin{2})) ...
                    && (iscellstr(varargin{3}) || ischar(varargin{3}))
                This.userFunc = varargin{1};
                dataList = varargin{2};
                paramList = varargin{3};
                varargin(1:3) = [];
                opt = passvalopt('likfunc.likfunc',varargin{:});
                This.form = lower(strrep(opt.form,' ',''));
                This = userdata(This,opt.userdata);
                This = comment(This,opt.comment);
                This = myvalidate(This,dataList,paramList);
                return
            end
            utils.error('likfunc:likfunc', ...
                'Invalid input arguments.');
        end  
        
    end
    %{
    methods
        varargout = data4eval(varargin)
        varargout = eval(varargin)
        varargout = estimate(varargin)
    end
    
    methods (Hidden)
        disp(varargin)
        varargout = objfunc(varargin)
    end
    
    methods (Access=protected,Hidden)
        varargout = myparamstruct(varargin)
        varargout = myvalidate(varargin)
    end
    %}
    
end