classdef reportobj < report.genericobj
    % reportobj  [Not a public class] Top level report object.
    %
    % Backed IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.
    
    properties
        longTable = false;
        footnoteCounter = 0;
        tempDirName = '';
        figureHandle = zeros(1,0);
        tempFile = cell(1,0);
    end
    
    methods
        
        % Constructor
        %-------------
        function This = reportobj(varargin)
            This = This@report.genericobj(varargin{:});
            This.default = [This.default,{ ...
                'centering',true,@islogicalscalar,false, ...
                'orientation','landscape', ...
                @(x) any(strcmpi(x,{'landscape','portrait'})),false, ...
                'typeface','',@ischar,false, ...
                }];
            This.parent = [];
        end
        
        % Destructor
        %------------
        function delete(This)
            cleanup(This);
        end
        
        varargout = cleanup(varargin)
        varargout = merge(varargin)
        varargout = publish(varargin)
        
    end
    
    methods (Access=protected,Hidden)
        varargout = speclatexcode(varargin)
        varargout = add(varargin)
    end
    
    
    methods (Hidden)
        
        % Event callbacks
        %-----------------
        function cbOpenFigureWindow(This,EventObj,~)
            This.figureHandle(end+1) = EventObj.handle;
        end
        
        function cbNewTempFile(This,~,EventData)
            This.tempFile = [This.tempFile,EventData.data];
        end
        
        function cbLongTable(This,~,~)
            This.longTable = true;
        end

    end
    
    
    methods
        
        % Level 1 objects
        %-----------------
        
        function This = section(This,varargin)
            newObj = report.sectionobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
        end
        
        function This = table(This,varargin)
            newObj = report.tableobj(varargin{:});
            % Register listeners
            %--------------------
            addlistener(newObj,'longTable', ...
                @This.cbLongTable);
            This = add(This,newObj,varargin{2:end});
        end
        
        function This = matrix(This,varargin)
            newObj = report.matrixobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
            % Register listeners
            %--------------------
            addlistener(newObj,'longTable', ...
                @This.cbLongTable);
        end
        
        function This = array(This,varargin)
            newObj = report.arrayobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
            % Register listeners
            %--------------------
            addlistener(newObj,'longTable', ...
                @This.cbLongTable);
        end
        
        function This = figure(This,varargin)
            if length(varargin) == 1 || ischar(varargin{2})
                newObj = report.figureobj(varargin{:});
                This = add(This,newObj,varargin{2:end});
                % Register listeners
                %--------------------
                addlistener(newObj,'openFigureWindow', ...
                    @This.cbOpenFigureWindow);
                addlistener(newObj,'newTempFile', ...
                    @This.cbNewTempFile);
            else
                % For bkw compatibility.
                % ##### Nov 2013 OBSOLETE and scheduled for removal.
                utils.warning('obsolete', ...
                    ['Using report/figure for inserting existing figure ', ...
                    'windows into the report is obsolete, and this feature ', ...
                    'will be removed from IRIS in a future release. ', ...
                    'Use report/userfigure instead.']);
                This = userfigure(This,varargin{:});
            end
        end
        
        function This = userfigure(This,varargin)
            newObj = report.userfigureobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
            % Register listeners
            %--------------------
            addlistener(newObj,'openFigureWindow', ...
                @This.cbOpenFigureWindow);
            addlistener(newObj,'newTempFile', ...
                @This.cbNewTempFile);
        end
        
        function This = tex(This,varargin)
            newObj = report.texobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
        end
        
        function This = texcommand(This,varargin)
            newObj = report.texcommandobj(varargin{1});
            This = add(This,newObj,varargin{2:end});
        end
        
        function This = text(This,varargin)
            This = tex(This,varargin{:});
        end
        
        function This = include(This,varargin)
            newObj = report.includeobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
        end
        
        function This = modelfile(This,varargin)
            newObj = report.modelfileobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
        end
        
        function This = pagebreak(This,varargin)
            newObj = report.pagebreakobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
        end
        
        function This = clearpage(This,varargin)
            This = pagebreak(This,varargin{:});
        end
        
        function This = align(This,varargin)
            newObj = report.alignobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
        end
        
        function This = empty(This,varargin)
            newObj = report.emptyobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
        end
        
        % Level 2 and 3 objects
        %-----------------------
        
        function This = graph(This,varargin)
            newObj = report.graphobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
        end
        
        function This = series(This,varargin)
            newObj = report.seriesobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
        end
        
        function This = band(This,varargin)
            newObj = report.bandobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
        end
        
        function This = fanchart(This,varargin)
            newObj = report.fanchartobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
        end
        
        function This = vline(This,varargin)
            newObj = report.vlineobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
        end
        
        function This = highlight(This,varargin)
            newObj = report.highlightobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
        end
        
        function This = subheading(This,varargin)
            newObj = report.subheadingobj(varargin{:});
            This = add(This,newObj,varargin{2:end});
        end
        
    end
    
end