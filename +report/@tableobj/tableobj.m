classdef tableobj < report.tabularobj
    
    properties (Dependent)
        range
    end
    
    methods
        
        function This = tableobj(varargin)
            This = This@report.tabularobj(varargin{:});
            This.childof = {'report','align'};
            This.default = [This.default,{ ...
                'colstruct,columnstruct',struct([]), ...
                @(x) isempty(x) || report.genericobj.validatecolstruct(x), ...
                true, ...
                'datejustify',[], ...
                @(x) isempty(x) || (ischar(x) && any(strncmpi(x,{'c','l','r'},1))), ...
                true, ...
                'colfootnote,columnfootnote',{},@(x) isempty(x) ...
                || (iscell(x) && all(cellfun(@is.numericscalar,x(1:2:end))) && iscellstr(x(2:2:end))), ...
                true, ...
                'dateformat',irisget('dateformat'), ...
                @(x) ischar(x) || iscellstr(x), ...
                true, ...
                'headlinejust','c', ...
                @(x) ischar(x) && any(strncmp(x,{'c','l','r'},1)), ...
                true, ...
                'highlight',[],@isnumeric,true, ...
                'range',[],@isnumeric,true, ...
                'separator','\medskip\par',@ischar,true, ...
                'typeface','',@ischar,false, ...
                'vline',[],@isnumeric,true, ...
                }];
            This.nlead = 3;
        end % table()
        
        
        function This = setoptions(This,varargin)
            % Call superclass setoptions to get all options assigned.
            This = setoptions@report.tabularobj(This,varargin{:});
            if isempty(This.options.colstruct) ...
                    && isempty(This.options.range)
                utils.error('report', ...
                    ['In table(), either ''range='' or ''colstruct='' ', ...
                    'must be specified.']);
            end
            isDates = isempty(This.options.colstruct);
            if ~isDates
                ncol = length(This.options.colstruct);
                This.options.range = 1 : ncol;
                for i = 1 : ncol
                    if ischar(This.options.colstruct(i).name)
                        This.options.colstruct(i).name = {NaN, ...
                            This.options.colstruct(i).name};
                    end
                end
            end
            
            if isempty(This.options.colstruct)
                tmpRange = This.options.range;
            else
                tmpRange = 1 : length(This.options.colstruct);
            end
            tmpRange = [tmpRange(1)-1,tmpRange];
            
            % Find positions of vertical lines.
            This.vline = zeros(1,0);
            for i = This.options.vline(:).'
                inx = datcmp(i,tmpRange);
                if any(inx)
                    This.vline(1,end+1) = find(inx) - 1;
                end
            end
            
            % Find positions of highlighted columns.
            This.highlight = zeros(1,0);
            for i = This.options.highlight(:).'
                inx = datcmp(i,tmpRange);
                if any(inx)
                    This.highlight(1,end+1) = find(inx) - 1;
                end
            end
            if ~isempty(This.highlight)
                This.hInfo.package.colortbl = true;
            end
            
            % Add vertical lines wherever the date frequency changes.
            [~,~,freq] = dat2ypf(This.options.range);
            This.vline = ...
                unique([This.vline,find([false,diff(freq) ~= 0]) - 1]);
            if ischar(This.options.datejustify)
                utils.warning('report', ...
                    ['The option ''datejustify'' in report/band is obsolete ', ...
                    'and will be removed from future IRIS versions. ', ...
                    'Use ''headlinejust'' instead.']);
                This.options.headlinejust = This.options.datejustify;
            end
            This.options.headlinejust = lower(This.options.headlinejust(1));

            % Date format is converted to cellstr, first cell is format for the first
            % dateline or NaN, second cell is format for the second or main dateline.
            if ischar(This.options.dateformat)
                This.options.dateformat = {NaN,This.options.dateformat};
            elseif iscell(This.options.dateformat) ...
                    && length(This.options.dateformat) == 1
                This.options.dateformat = [{NaN},This.options.dateformat];
            end    
        end % setoptions()
        
        
        varargout = headline(varargin)
        
    end

    
    methods (Access=protected,Hidden)
        varargout = speclatexcode(varargin)
    end
    
    
end
