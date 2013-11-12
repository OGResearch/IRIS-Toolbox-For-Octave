classdef theparser
    % theparser  [Not a public class] IRIS parser.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.
    
    properties
        fname = '';
        code = '';
        caller = '';
        labels = cell(1,0);
        blkName = cell(1,0);
        altBlkName = cell(0,2);
        altBlkNameWarn = cell(0,2);
        nameBlk = false(1,0);
        nameType = nan(1,0);
        eqtnBlk = false(1,0);
        flagBlk = false(1,0);
        flaggable = false(1,0);
        essential = false(1,0);
        otherKey = cell(1,0);
    end
    
    methods
        
        function This = theparser(varargin)
            if isempty(varargin)
                return
            end
            if length(varargin) == 1 && isa(varargin{1},'theparser')
                This = varargin{1};
                return
            end
            if length(varargin) == 1 && isa(varargin{1},'preparser')
                This.fname = varargin{1}.fname;
                This.code = varargin{1}.code;
                This.labels = varargin{1}.labels;
                return
            end
            if length(varargin) == 2 ...
                    && ischar(varargin{1}) && isa(varargin{2},'preparser')
                This.fname = varargin{2}.fname;
                This.code = varargin{2}.code;
                This.labels = varargin{2}.labels;
                % Initialise class-specific theta parser.
                switch varargin{1}
                    case 'model'
                        This = model(This);
                    case 'systemfit'
                        This = systemfit(This);
                end
                return
            end
        end
        
        varargout = altsyntax(varargin)
        varargout = errorparsing(varargin)
        varargout = parse(varargin)
        varargout = parseeqtns(varargin)
        varargout = parseflags(varargin);
        varargout = parsenames(varargin)
        varargout = readblk(varargin)
    end
    
    methods (Access=protected)
        
        varargout = model(varargin)
        
    end
    
end