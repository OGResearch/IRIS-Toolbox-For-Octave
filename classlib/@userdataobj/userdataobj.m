classdef userdataobj
    % userdataobj  [Not a public class] Implement user data and comments for other classes.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2014 IRIS Solutions Team.
    
    properties (GetAccess=public,SetAccess=protected,Hidden)
        % User data attached to IRIS objects.
        UserData = [];
        % User comments attached to IRIS objects.
        Comment = '';
        % User captions used to title graphs.
        Caption = '';
        % Base year for time trends.
        BaseYear = @config;
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
        
        varargout = caption(varargin)
        varargout = comment(varargin)
        varargout = userdata(varargin)
        varargout = userdatafield(varargin)
        
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