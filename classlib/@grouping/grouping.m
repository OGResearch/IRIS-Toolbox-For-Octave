classdef grouping < userdataobj & getsetobj
    % grouping  Grouping Objects for Aggregation of Contributions.
    %
    % Grouping objects can be used for aggregating the contributions of shocks
    % in model simulations, [`model/simulate`](model/simulate), or aggregating
    % the contributions of measurement variables in Kalman filtering,
    % [`model/filter`](model/filter).
    %
    % Grouping methods:
    %
    % Constructor
    % ============
    %
    % * [`grouping`](grouping/grouping) - Create new, empty grouping object.
    %
    % Getting information about groups
    % =================================
    %
    % * [`detail`](grouping/detail) - Details of a grouping object.
    % * [`isempty`](grouping/isempty) - True for empty grouping object.
    %
    % Setting up and using groups
    % ============================
    %
    % * [`addgroup`](grouping/addgroup) - Add measurement variable group or shock group to grouping object.
    % * [`eval`](grouping/eval) - Evaluate contributions in input database S using grouping object G.
    %
    % Getting on-line help on groups
    % ===============================
    %
    %     help grouping
    %     help grouping/function_name
    %
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2014 IRIS Solutions Team.
    
    properties ( Hidden) %GetAccess=protected, SetAccess=protected,
        type = '' ;
        groupNames = cell(1,0) ;
        groupContents = cell(1,0) ;
        
        logVars = struct() ;
        list = cell(1,0) ;
        descript = cell(1,0) ;
        
        otherName = 'Other';
%         constName = 'Init+Const';
%         nonlinName = 'Nonlinear';
    end
    
    properties (Hidden, Dependent)
        otherContents ;
    end
    
    methods
        
        function This = grouping(varargin)
            % grouping  Create new, empty grouping object.
            %
            % Syntax
            % =======
            %
            %     G = grouping(M,Type)
            %
            % Input arguments
            % ================
            %
            % * `M` [ model ] - Model object.
            %
            % * `Type` [ `'shock'` | `'measurement'` ] - Type of grouping object.
            %
            % Output arguments
            % =================
            %
            % * `G` [ grouping ] - New, empty grouping object.
            %
            % Description
            % ============
            %
            % Example
            % ========
            %
            
            % -IRIS Toolbox.
            % -Copyright (c) 2007-2014 IRIS Solutions Team.
            
            This = This@userdataobj();
            This = This@getsetobj();
            
            if isempty(varargin)
                return
            end
            
            if length(varargin) == 1 && isa(varargin{1},'grouping')
                This = varargin{1};
                return
            end
            
            M = varargin{1};
            Type = varargin{2};
            
            pp = inputParser();
if ismatlab
            pp.addRequired('M',@(x) isa(x,'modelobj'));
            pp.addRequired('Type',@(x) ischar(x) ...
                && any(strncmpi(x,{'shock','measu'},5)));
            pp.parse(M,Type);
else
            pp = pp.addRequired('M',@(x) isa(x,'modelobj'));
            pp = pp.addRequired('Type',@(x) ischar(x) ...
                && any(strncmpi(x,{'shock','measu'},5)));
            pp = pp.parse(M,Type);
end

            switch lower(Type(1:5))
                case 'shock'
                    This.type = 'shocks';
                    listRequest = 'eList';
                    descriptRequest = 'eDescript';
                case 'measu'
                    This.type = 'measurement';
                    listRequest = 'yList';
                    descriptRequest = 'yDescript';
                otherwise
                    utils.error('grouping:grouping', ...
                        'Unknown grouping type: ''%s''.', ...
                        This.type);
            end
            This.list = get(M,listRequest) ;
            This.descript = get(M,descriptRequest) ;
            This.logVars = get(M,'log') ;
        end

        varargout = addgroup(varargin)
        varargout = detail(varargin)
        varargout = eval(varargin)
        varargout = isempty(varargin)
        varargout = rmgroup(varargin)
        varargout = splitgroup(varargin)
        
        varargout = get(varargin)
        varargout = set(varargin)
        
        function otherContents = get.otherContents(This)
            allGroupContents = any([This.groupContents{:}],2);
            otherContents = ~allGroupContents;
        end
        
    end
    
    methods (Hidden)
        
        varargout = disp(varargin)
        
    end
    
end