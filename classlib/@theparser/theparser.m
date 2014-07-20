classdef theparser
    % theparser  [Not a public class] IRIS parser.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2014 IRIS Solutions Team.
    
    properties
        FName = '';
        Code = '';
        Caller = '';
        Labels = fragileobj();
        Assign = struct();
        BlkName = cell(1,0);
        AltBlkName = cell(0,2);
        AltBlkNameWarn = cell(0,2);
        IxNameBlk = false(1,0);
        NameType = nan(1,0);
        IxStdcorrAllowed = false(1,0); % Stdcorr declarations allowed here.
        IxStdcorrBasis = false(1,0); % Stdcorr names derived from these names.
        IxEqtnBlk = false(1,0);
        IxLogBlk = false(1,0);
        IxLoggable = false(1,0);
        IxEssential = false(1,0);
        OtherKey = cell(1,0);
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
                This.Caller = varargin{1};
                switch This.Caller
                    case 'model'
                        This = model(This);
                    otherwise
                        utils.error('theparser:theparser', ...
                            'Invalid caller class ''%s''.', ...
                            This.Caller);
                end
                
                % Copy info from preparser.
                if length(varargin) >= 2 && isa(varargin{2},'preparser')
                    doCopyPreparser(varargin{2});
                end
                
            end
             
            function doCopyPreparser(Pre)
                This.FName = Pre.FName;
                This.Code = Pre.Code;
                This.Labels = Pre.Labels;
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
