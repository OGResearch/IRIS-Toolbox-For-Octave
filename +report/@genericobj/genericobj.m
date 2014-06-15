classdef genericobj < handle
    % genericobj  [Not a public class] Generic report object.
    %
    % Backed IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2014 IRIS Solutions Team.
    
    properties
        parent = [];
        children = {};
        childof = {};
        caption = '';
        options = struct();
        default = {};
        
        hInfo = []; % Store a handle object to carry global information.
    end
    
    properties (Dependent)
        title
        subtitle
    end
    
    methods
        
        
        function This = genericobj(varargin)
            This.default = [This.default,{ ...
                'captionformat',[],@(x) isempty(x) ...
                || ischar(x) || ...
                (iscell(x) && length(x) == 2 ...
                && (ischar(x{1}) || isequal(x{1},Inf)) ...
                && (ischar(x{2}) || isequal(x{2},Inf))), ...
                true, ...
                'captiontypeface',{'\large\bfseries',''}, ...
                @(x) ischar(x) || ...
                (iscell(x) && length(x) == 2 ...
                && (ischar(x{1}) || isequal(x{1},Inf)) ...
                && (ischar(x{2}) || isequal(x{2},Inf))), ...
                true, ...
                'footnote','',@ischar,false, ...
                'inputformat','plain', ...
                @(x) any(strcmpi(x,{'plain','latex'})),true,...
                'saveas','',@ischar,false, ...
                }];
            if ~isempty(varargin)
                This.caption = varargin{1};
            end
        end % genericobj()
        
        
        function [This,varargin] = specargin(This,varargin)
        end % specargin()
        
        
        function This = setoptions(This,ParentOpt,varargin)
            % The function `setoptions()` is called from within `add()`.
            try
                % Convert argins to struct.
                userName = varargin(1:2:end);
                userValue = varargin(2:2:end);
                % Make option names lower-case and remove equal signs.
                userName = lower(userName);
                userName = strrep(userName,'=','');
                % useropt = cell2struct(uservalues,usernames,2);
            catch Error
                utils.error('report',...
                    ['Invalid structure of optional input arguments.\n', ...
                    'MATLAB says: %s'],...
                    Error.message);
            end
            % First, pool parent's and user-supplied options; some of them may not
            % apply to this object, but can be inherited by children.
            This.options = ParentOpt;
            for i = 1 : length(userName)
                This.options.(userName{i}) = userValue{i};
            end
            Default = This.default;
            % Process the object-specific options.
            for i = 1 : 4 : length(Default)
                match = regexp(Default{i},'\w+','match');
                defValue = Default{i+1};
                validateFunc = Default{i+2};
                isInheritable = Default{i+3};
                primaryName = match{1};
                % First, assign default under the primary name.
                This.options.(primaryName) = defValue;
                for j = 1 : length(match)
                    optName = match{j};
                    % Then, inherit the value from the parent object if it is inheritable and
                    % is available from parent options.
                    if isInheritable && isfield(ParentOpt,optName)
                        This.options.(primaryName) = ParentOpt.(optName);
                    end
                    % Last, get it from current user options if supplied.
                    invalid = {};
                    index = strcmpi(optName,userName);
                    if any(index)
                        valuePos = find(index);
                        % Validate user option.
                        if feval(validateFunc,userValue{valuePos})
                            This.options.(primaryName) = userValue{valuePos};
                        else
                            invalid{end+1} = optName; %#ok<AGROW>
                            invalid{end+1} = func2str(validateFunc); %#ok<AGROW>
                        end
                        % Report values that do not pass validation.
                        if ~isempty(invalid)
                            utils.error('report',...
                                ['Value assigned to option ''%s='' ', ...
                                'does not pass validation ''%s''.'],...
                                invalid{:});
                        end
                    end
                end
            end
            % Obsolete option names.
            if ~isempty(This.options.captionformat)
                utils.warning('report', ...
                    ['The option ''captionformat'' is obsolete ', ...
                    'and will be removed from future IRIS versions. ', ...
                    'Use ''captiontypeface'' instead.']);
                This.options.captiontypeface = This.options.captionformat;
                This.options.captionformat = [];
            end
        end % setoptions()
        
        
        varargout = copy(varargin)
        varargout = disp(varargin)
        varargout = display(varargin)
        varargout = findall(varargin)
        
    end
    
    methods (Access=protected)
        varargout = interpret(varargin)
        varargout = latexcode(varargin)
        varargout = root(varargin)
        varargout = speclatexcode(varargin)
        varargout = shortclass(varargin)
        varargout = printcaption(varargin)
    end
    
    methods
        
        
        function Title = get.title(This)
            if ischar(This.caption)
                Title = This.caption;
            elseif iscellstr(This.caption) && ~isempty(This.caption)
                Title = This.caption{1};
            else
                Title = '';
            end
        end % get.title()
        
        
        function Subtitle = get.subtitle(This)
            if iscellstr(This.caption) && length(This.caption) > 1
                Subtitle = This.caption{2};
            else
                Subtitle = '';
            end
        end % get.subtitle()
        
        
    end
    
    methods (Access=protected,Hidden)
        
        
        function C = mytitletypeface(This)
            if iscell(This.options.captiontypeface)
                C = This.options.captiontypeface{1};
            else
                C = This.options.captiontypeface;
            end
            if isinf(C)
                C = '\large\bfseries';
            end
        end % mytitletypeface()
        
        
        function C = mysubtitletypeface(This)
            if iscell(This.options.captiontypeface)
                C = This.options.captiontypeface{2};
            else
                C = '';
            end
            if isinf(C)
                C = '';
            end
        end % mysubtitletypeface()
        
        
        % When adding a new object, we find the right place by checking two things:
        % first, we match the child's childof list, and second, we ask the parent
        % if it accepts new childs. The latter test is true for all parents except
        % align objects with no more room.
        function Flag = accepts(This) %#ok<MANU>
            Flag = true;
        end % accepts()
                
        
        % User-supplied typeface
        %------------------------
        
        
        function C = begintypeface(This)
            C = '';
            if isfield(This.options,'typeface') ...
                    && ~isempty(This.options.typeface)
                br = sprintf('\n');
                C = [C,'{',br,This.options.typeface,br];
            end
        end % begintypeface()
        
        
        function C = endtypeface(This)
            C = '';
            if isfield(This.options,'typeface') ...
                    && ~isempty(This.options.typeface)
                br = sprintf('\n');
                C = [C,'}',br];
            end
        end % endtypeface()
        
        
        % hInfo methods
        %---------------
        
        
        function addtempfile(This,NewTempFile)
            if ischar(NewTempFile)
                NewTempFile = {NewTempFile};
            end
            tempFile = This.hInfo.tempFile;
            tempFile = [tempFile,NewTempFile];
            This.hInfo.tempFile = tempFile;
        end % addtempfile()
        
        
        function addfigurehandle(This,NewFigureHandle)
            figureHandle = This.hInfo.figureHandle;
            figureHandle = [figureHandle,NewFigureHandle];
            This.hInfo.figureHandle = figureHandle;
        end % addfigurehandle()

        
        function C = footnotemark(This,Text)
            try
                Text; %#ok<VUNUS>
            catch
                try
                    Text = This.options.footnote;
                catch
                    Text = '';
                end
            end
            if isempty(Text)
                C = '';
                return
            end
            br = sprintf('\n');
            number = sprintf('%g',footnotenumber(This));
            Text = interpret(This,Text);
            C = ['\footnotemark[',number,']'];
            This.hInfo.footnote{end+1} = [br, ...
                '\footnotetext[',number,']{',Text,'}'];
        end % footnotemark()
        
        
        function C = footnotetext(This)
            footnote = This.hInfo.footnote;
            if isempty(footnote)
                C = '';
                return
            end
            C = [footnote{:}];
            footnote = {};
            This.hInfo.footnote = footnote;
        end % footnotetext()
        
        
        function N = footnotenumber(This)
            N = This.hInfo.footnoteCount;
            N = N + 1;
            This.hInfo.footnoteCount = N;
        end % footnotenumber()
        
        
    end
    
    
    methods (Static,Hidden)
        
        
        function C = makebox(Text,Format,ColW,Pos,Color)
            C = ['{',Text,'}'];
            if ~isempty(Format)
                C = ['{',Format,C,'}'];
            end
            if ~isnan(ColW)
                C = ['\makebox[',sprintf('%g',ColW),'em]', ...
                    '[',Pos,']{',C,'}'];
            end
            if ~isempty(Color)
                C = ['\colorbox{',Color,'}{',C,'}'];
            end
        end % makebox()
        
        
        function C = sprintf(Value,Format,Opt)
            if ~isempty(Opt.purezero) && Value == 0
                C = Opt.purezero;
                return
            end
            if isnan(Value)
                C = Opt.nan;
                return
            end
            if isinf(Value)
                C = Opt.inf;
                return
            end
            d = sprintf(Format,Value);
            if ~isempty(Opt.printedzero) ...
                    && isequal(sscanf(d,'%g'),0)
                d = Opt.printedzero;
            end
            C = ['\ensuremath{',d,'}'];
        end % sprintf()
        
        
        function C = turnbox(C,Angle)
            try
                if islogical(Angle)
                    Angle = '90';
                else
                    Angle = sprintf('%g',Angle);
                end
            catch %#ok<CTCH>
                Angle = '90';
            end
            C = ['\settowidth{\tableColNameHeight}{',C,' }',...
                '\rule{0pt}{\tableColNameHeight}',...
                '\turnbox{',Angle,'}{',C,'}'];
        end % turnbox()
        
        
        function Valid = validatecolstruct(ColStruct)
            Valid = true;
            for i = 1 : length(ColStruct)
                c = ColStruct(i);
                if ~(ischar(c.name) ...
                        || ( ...
                        iscell(c.name) && length(c.name) == 2 ...
                        && (ischar(c.name{1}) || isequaln(c.name{1},NaN)) ...
                        && (ischar(c.name{2}) || isequaln(c.name{2},NaN)) ...
                        )) %#ok<FPARK>
                    Valid = false;
                end
                if ~isempty(c.func) ...
                        && isa(c,'function_handle')
                    Valid = false;
                end
                if ~isempty(c.date) ...
                        && ~is.numericscalar(c.date)
                    Valid = false;
                end
            end
        end % validatecolstruct()
        
    end
    
end