classdef varobj < userdataobj & getsetobj
    % varobj  [Not a public class] Superclass for VAR based models.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.

    properties
        A = []; % Transition matrix.
        Ynames = {};
        Enames = {};
        GroupNames = {};
        range = zeros(1,0);
        fitted = false(1,0);
        Omega = zeros(0);
        eigval = zeros(1,0);
    end
    
    methods
        varargout = group(varargin)
        varargout = isempty(varargin)
        varargout = iscompatible(varargin)
        varargout = ispanel(varargin)
        varargout = nfitted(varargin)
    end
    
    methods (Hidden)
        disp(varargin)
    end
    
    methods (Access=protected,Hidden)
        varargout = myenames(varargin)
        varargout = mygroupnames(varargin)
        varargout = myinpdata(varargin)
        varargout = mynalt(varargin)
        varargout = myny(varargin)       
        varargout = myoutpdata(varargin)
        varargout = mysubsalt(varargin)
        varargout = myynames(varargin)
        specdisp(varargin)
    end
    
    methods (Static,Hidden)
        varargout = mydatarequest(varargin)
    end
    
    % Constructor
    %-------------
    methods
        function This = varobj(varargin)
            if ~isempty(varargin) ...
                    && (iscellstr(varargin{1}) || ischar(varargin{1}))
                % Assign variable names.
                This = myynames(This,varargin{1});
                varargin(1) = [];
                if ~isempty(varargin) ...
                        && (iscellstr(varargin{1}) || ischar(varargin{1}))
                    % Assign group names.
                    This = mygroupnames(This,varargin{1});
                    varargin(1) = [];
                end
                % Create residual names.
                This = myenames(This,[]);
            end
            if ~isempty(varargin) && iscellstr(varargin(1:2:end))
                opt = passvalopt('varobj.varobj',varargin{:});
                if ~isempty(opt.userdata)
                    This = userdata(This,opt.userdata);
                end
            end
        end
    end
    
end