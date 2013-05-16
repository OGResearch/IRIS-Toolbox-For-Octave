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
        
        varargout = userdata(varargin)
        varargout = userdatafield(varargin)
        varargout = comment(varargin)
        
    end
    
    methods (Hidden)
        varargout = disp(varargin)
        varargout = display(varargin)
    end
    
    methods (Access=protected,Hidden)
        varargout = dispcomment(varargin)
        varargout = dispuserdata(varargin)
    end
    
end