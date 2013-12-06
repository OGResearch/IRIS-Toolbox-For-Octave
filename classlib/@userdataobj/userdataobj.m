classdef userdataobj
    % userdataobj  [Not a public class] Implement user data and comments for other classes.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.
    
    properties (GetAccess=public,SetAccess=protected,Hidden)
        % User data attached to IRIS objects.
        UserData = [];
        % User comments attached to IRIS objects.
        Comment = '';
        % User captions used to title graphs.
        Caption = '';
    end
    
    methods
        
        function this = userdataobj(varargin)
            if isempty(varargin)
                return
            end
            if isa(varargin{1},'userdataobj')
                this = varargin{1};
            else
                this.UserData = varargin{1};
            end
        end
        
        function varargout = caption(this,varargin)
            varargout{1} = caption_4oct(this,varargin{:});
        end
        function varargout = comment(this,varargin)
            varargout{1} = comment_4oct(this,varargin{:});
        end
        function varargout = userdata(this,varargin)
            varargout{1} = userdata_4oct(this,varargin{:});
        end
        function varargout = userdatafield(this,Field,varargin)
            varargout{1} = userdatafield_4oct(this,Field,varargin{:});
        end
        
    end
    
    methods (Hidden)
        function disp(this)
            disp_4oct(this)
        end
        function varargout = display(this)
            display_4oct(this)
        end
    end
    
    methods %(Access=protected,Hidden)
        function dispcomment(this)
            dispcomment_4oct(this);
        end
        function dispuserdata(this)
            dispuserdata_4oct(this);
        end
    end
    
end