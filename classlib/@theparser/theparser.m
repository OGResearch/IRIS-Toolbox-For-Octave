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
        blkname = cell(1,0);
        altblkname = cell(0,2);
        altblknamewarn = cell(0,2);
        chkallbut = false(1,0);
        nameblk = false(1,0);
        nameType = nan(1,0);
        eqtnblk = false(1,0);
        flagblk = false(1,0);
        flaggable = false(1,0);
        essential = false(1,0);
        otherkey = cell(1,0);
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
        varargout = readblk(varargin)
    end
    
    methods (Access=protected)
        
        varargout = model(varargin)

    end

    methods (Static)
       
        varargout = evaltimesubs(varargin)
        varargout = getalias(varargin)
        varargout = parsenames(varargin)
        varargout = parseeqtns(varargin)
        varargout = parseflags(varargin)
        varargout = sstateonly(varargin)
        
    end
    
end