classdef varobj < userdataobj & getsetobj
    % varobj  [Not a public class] Superclass for VAR based models.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.

    
    properties
        A = []; % Transition matrix.
        Ynames = {}; % Endogenous variables.
        Enames = {}; % Residuals.
        Qnames = {}; % Exogenous variables.
        GroupNames = {}; % Panel groups.
        range = zeros(1,0);
        fitted = false(1,0);
        Omega = zeros(0);
        eigval = zeros(1,0);
    end
    
    
    methods
        varargout = group(varargin)
        varargout = isempty(varargin)
        varargout = ispanel(varargin)
        varargout = nfitted(varargin)
    end
    
    
    methods (Hidden)
        disp(varargin)
        varargout = mydatarequest(varargin)
        varargout = myinpdata(varargin)
        varargout = myoutpdata(varargin)
        varargout = myselect(varargin)        
        varargout = specget(varargin)
    end
    
    
    methods (Access=protected,Hidden)
        varargout = mycompatible(varargin)
        varargout = myenames(varargin)
        varargout = mygroupnames(varargin)
        varargout = mynalt(varargin)
        varargout = myny(varargin)       
        varargout = mysubsalt(varargin)
        varargout = myynames(varargin)
        specdisp(varargin)
    end
    
    
    methods (Static,Hidden)
        varargout = mytelltime(varargin)
    end
    
    
    methods
        
        function This = varobj(varargin)
            
            if isempty(varargin)
                return
            end
            
            if length(varargin) == 1 && isa(varargin,'varobj')
                This = varargin{1};
                return
            end
            
            % Assign endogenous variable names, and create residual names.
            if iscellstr(varargin{1}) || ischar(varargin{1})
                This = myynames(This,varargin{1});
                varargin(1) = [];
                This = myenames(This,[]);
            end
            
            % Assign group names.
            if ~isempty(varargin) ...
                    && (iscellstr(varargin{1}) || ischar(varargin{1}))
                This = mygroupnames(This,varargin{1});
                varargin(1) = [];
            end

            % Options and userdata.
            if ~isempty(varargin) && iscellstr(varargin(1:2:end))
                opt = passvalopt('varobj.varobj',varargin{:});
                if ~isempty(opt.userdata)
                    This = userdata(This,opt.userdata);
                end
            end
        end
        
    end
    

end