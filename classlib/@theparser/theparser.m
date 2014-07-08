classdef theparser
    % theparser  [Not a public class] IRIS parser.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2014 IRIS Solutions Team.
    
    properties
        FName = '';
        code = '';
        caller = '';
        labels = fragileobj();
        Assign = struct();
        blkName = cell(1,0);
        altBlkName = cell(0,2);
        altBlkNameWarn = cell(0,2);
        IxNameBlk = false(1,0);
        nameType = nan(1,0);
        IxStdcorrAllowed = false(1,0); % Stdcorr declarations allowed here.
        IxStdcorrBasis = false(1,0); % Stdcorr names derived from these names.
        IxEqtnBlk = false(1,0);
        IxLogBlk = false(1,0);
        IxLoggable = false(1,0);
        IxEssential = false(1,0);
        otherKey = cell(1,0);
        AssignBlkOrd = cell(1,0); % Order in which values assigned to names will be evaluated.
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
                doCopyPreparser(varargin{1});
                return
            end
            
            if length(varargin) >= 1 && ischar(varargin{1})
                % Initialise class-specific theta parser.
                This.caller = varargin{1};
                switch This.caller
                    case 'model'
                        This = model(This);
                    otherwise
                        utils.error('theparser:theparser', ...
                            'Invalid caller class ''%s''.', ...
                            This.caller);
                end
                
                % Copy info from preparser.
                if length(varargin) >= 2 && isa(varargin{2},'preparser')
                    doCopyPreparser(varargin{2});
                end
                
            end
             
            function doCopyPreparser(Pre)
                This.FName = Pre.FName;
                This.code = Pre.code;
                This.labels = Pre.labels;
                This.Assign = Pre.Assign;
            end
        end
    end
    
    
    methods
        varargout = altsyntax(varargin)
        varargout = blkpos(varargin)
        varargout = parse(varargin)
        varargout = parseeqtns(varargin)
        varargout = parselog(varargin);
        varargout = parsenames(varargin)
        varargout = readblk(varargin)
        varargout = specget(varargin)
    end
    
    
    methods (Static)
        varargout = stdcorrindex(varargin)
    end
    
    
    methods (Access=protected)
        varargout = model(varargin)
    end
    
end