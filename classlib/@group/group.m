classdef group < userdataobj & getsetobj
    % group  Grouping object for aggregation.
    %
    % Group objects complement the use of the
    % [`model/simulate`](model/simulate) or
    % [`model/filter`](model/filter) functions
    % when contributions are requested.
    %
    % Group methods:
    %
    % Constructor
    % ============
    %
    % * [`group`](group/group) - Create new grouping object.
    %
    % Getting information about groups
    % ===========================================
    %
    % * [`detail`](group/detail) - Display details of a group.
    % * [`get`](group/get) - Query to group object.
    %
    % Setting up and using groups
    % ============================
    %
    % * [`addgroup`](group/addgroup) - Add a group.
    % * [`groupcont`](group/groupcont) - Group contributions based on group object.
    % * [`legend`](group/legend) - Overloaded legend plot function. 
    %
    % Getting on-line help on groups
    % =========================================
    %
    %     help group
    %     help group/function_name
    %
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.
    
    properties ( Hidden) %GetAccess=protected, SetAccess=protected,
        groupNames = cell(1,0) ;
        groupContents = cell(1,0) ;
        type = '' ;
        
        logVars = struct() ;
        yList = cell(1,0) ;
        yDescript = cell(1,0) ;
        eList = cell(1,0) ;
        eDescript = cell(1,0) ;
    end
    
    properties (Hidden, Dependent = true)
        otherGroup ;
    end
    
    methods
        
        function This = group(M)
            % group  Create new group object.
            %
            % Syntax
            % =======
            %
            %     G = group(M)
            %
            % Input arguments
            % ================
            %
            % * `M` [ model ] - Model object.
            %
            % Output arguments
            % =================
            %
            % * `G` [ group ] - New, empty group object.
            %
            % Description
            % ============
            %
            %
            % Example
            % ========
            %
            
            % -IRIS Toolbox.
            % -Copyright (c) 2007-2013 IRIS Solutions Team.
            
            pp = inputParser();
            pp.addRequired('M',@(x) isa(x,'modelobj'));
            pp.parse(M);
            
            This = This@userdataobj();
            This = This@getsetobj();
            
            This.logVars = get(M,'log') ;
            This.yList = get(M,'yList') ;
            This.yDescript = get(M,'yDescript') ;
            This.eList = get(M,'eList') ;
            This.eDescript = get(M,'eDescript') ;
        end
        
        varargout = detail(varargin)
        varargout = addgroup(varargin)
        varargout = rmgroup(varargin)
        varargout = splitgroup(varargin)
        varargout = groupcont(varargin)
        varargout = legend(varargin)
        
        varargout = get(varargin)
        varargout = set(varargin)
        
        function otherGroup = get.otherGroup(This)
            switch This.type
                case 'shock'
                    thisList = This.eList ;
                case 'measurement'
                    thisList = This.yList ;
                otherwise
                    otherGroup = {} ;
                    return ;
            end
            otherInd = true(size(thisList)) ;
            
            for iGroup = 1:numel(This.groupNames)
                for iCont = 1:numel(This.groupContents{iGroup})
                    ind = strcmp(thisList,This.groupContents{iGroup}{iCont}) ;
                    if any(ind)
                        otherInd(ind) = false ;
                    end
                end
            end
            
            otherGroup = thisList(otherInd) ;
        end
        
    end
    
    methods (Hidden)
        
        varargout = disp(varargin)
        
    end
    
end