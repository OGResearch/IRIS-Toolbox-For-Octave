classdef preparser < userdataobj
% preparser  [Not a public class] IRIS pre-parser for model, sstate, and quick-report files.
%
% Backend IRIS class.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

    properties
        assign = struct();
        fname = '';
        code = '';
        labels = {};
        Export = {};
        subs = struct();
    end
        
    methods
        
        function This = preparser(varargin)
            % preparser  [Not a public function] General IRIS code preparser.
            %
            
            % p = preparser(inputFile,Opt)
            % p = preparser(inputFile,...)
            
            if nargin == 0
                return
            end

            if isa(varargin{1},'preparser')
                This = varargin{1};
                return
            end
            inputFiles = varargin{1};
            varargin(1) = [];
            if ischar(inputFiles)
                inputFiles = {inputFiles};
            end
            This.fname = inputFiles{1};
            for i = 2 : length(inputFiles)
                This.fname = [This.fname,' & ',inputFiles{2}];
            end
            % Parse options.
            if ~isempty(varargin) && isstruct(varargin{1})
                opt = varargin{1};
                varargin(1) = [];
            else
                [opt,varargin] = ...
                    passvalopt('preparser.preparser',varargin{:});
            end
            % Add remaining input arguments to the assign struct.
            if ~isempty(varargin) && iscellstr(varargin(1:2:end))
                for i = 1 : 2 : length(varargin)
                    opt.assign.(varargin{i}) = varargin{i+1};
                end
            end
            This.assign = opt.assign;
            % Read the code files and resolve preparser commands.
            [This.code,This.labels,This.Export, ...
                This.subs,This.Comment] = ...
                preparser.readcode(inputFiles, ...
                opt.assign,{},{},'',opt);
            % Create a clone of the preparsed code.
            if ~isempty(opt.clone)
                This.code = preparser.myclone(This.code,opt.clone);
            end
            % Save the pre-parsed file if requested by the user.
            if ~isempty(opt.saveas)
                saveas(This,opt.saveas);
            end
        end
        
        function disp(This)
            fprintf('\tpreparser object <a href="matlab:edit %s">%s</a>\n', ...
                This.fname,This.fname);
            disp@userdataobj(This);
            disp(' ');
        end
        
        varargout = saveas(varargin)
        
    end
    
    methods (Hidden)
        % TODO: Create reportingobj and make the parser its method.
        varargout = reporting(varargin)
    end
    
    methods (Static,Hidden)
        varargout = mychkclonestring(varargin)
        varargout = myclone(varargin)
        varargout = alt2str(varargin)
        varargout = export(varargin)
        varargout = grabcommentblk(varargin)
        varargout = labelsback(varargin)
        varargout = labeledexpr(varargin)
        varargout = lincomb2vec(varargin)
        varargout = controls(varargin)
        varargout = pseudofunc(varargin)
        varargout = readcode(varargin)
        varargout = substitute(varargin)
        varargout = protectlabels(varargin)
    end
    
end