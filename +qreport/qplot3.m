function [hfig,hax,hline,htit,plotdb] = qplot(cdfname,data,range,varargin)
% qplot  Create graphs based on a quick-report file.
%
% Syntax
% =======
%
%     [FF,AA,PDB] = qplot(FNAME,D,RANGE,...)
%
% Input arguments
% ================
%
% * `FNAME` [ char ] - Quick-report file name.
%
% * `D` [ struct ] - Database with input data.
%
% * `RANGE` [ numeric ] - Date range.
%
% Output arguments
% =================
%
% * `FF` [ numeric ] - Handles to figures created by `qplot`.
%
% * `AA` [ cell ] - Handles to axes created by `qplot`.
%
% * `PDB` [ struct ] - Database with actually plotted series.
%
% Options
% ========
%
% * `'addClick='` [ *`true`* | `false` ] - Make axes expand in a new graphics
% figure upon mouse click.
%
% * `'clear='` [ numeric | *empty* ] - Serial numbers of graphs (axes
% objects) that will not be displayed.
%
% * `'dbsave='` [ cellstr | *empty* ] - Options passed to `dbsave` when
% 'saveAs='` is used.
%
% * `'drawNow='` [ `true` | *`false`* ] - Call Matlab `drawnow` function upon
% completion of all figures.
%
% * `'grid='` [ *`true`* | `false` ] - Add grid lines to all graphs.
%
% * `'highlight='` [ numeric | cell | *empty* ] - Date range or ranges that
% will be highlighted.
%
% * `'mark='` [ cellstr | *empty* ] - Marks that will be added to each
% legend entry to distinguish individual columns of multivariated tseries
% objects plotted.
%
% * `'overFlow='` [ `true` | *`false`* ] - Open automatically a new figure
% window if the number of subplots exceeds the available total; if
% `'overFlow'=false` an error occurs instead.
%
% * `'prefix='` [ char | *'P%g_'* ] - Prefix (a `sprintf` format string)
% that will be used to precede the name of each entry in the `p` database.
%
% * `'round='` [ numeric | *`Inf`* ] - Round the input data to this number of
% decimals before plotting.
%
% * `'saveAs='` [ char | *empty* ] - File name under which the plotted data
% will be saved in a CSV file; you can use the `'dbsave='` option to control
% the options used when saving the data.
%
% * `'style='` [ struct | *empty* ] - Style structure that will be applied
% to all figures and their children created by the `qplot` function.
%
% * `'subplot='` [ *'auto'* | numeric ] - Default subplot division of
% figures, can be modified in the q-file.
%
% * `'sstate='` [ struct | model | *empty* ] - Database or model object
% from which the steady-state values referenced to in the quick-report
% file will be taken.
%
% * `'style='` [ struct | *empty* ] - Style structure that will be applied
% to all created figures upon completion.
%
% * `'transform='` [ function_handle | *empty* ] - Function that will be
% used to trans
%
% * `'title='` [ cellstr | *empty* ] - Strings that will be used for titles
% in the graphs that have no title in the q-file.
%
% * `'tight='` [ `true` | *`false`* ] - Make the y-axis in each graph tight.
%
% * `'vLine='` [ numeric | *empty* ] - Dates at which vertical lines will
% be plotted.
%
% * `'zeroLine='` [ `true` | *`false`* ] - Add a horizontal zero line to graphs
% whose y-axis includes zero.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Parse required input arguments.
p = inputParser();
p = p.addRequired('filename',@(x) ischar(x) || isfunc(x));
p = p.addRequired('dbase',@(x) isstruct(x));
p = p.addRequired('range',@isnumeric);
p = p.parse(cdfname,data,range);

% Parse options.
[options,varargin] = passvalopt('qreport.qplot',varargin{:});

if nargin < 3
    range = Inf;
end

if ischar(options.mark)
    options.mark = {options.mark};
end

options.mark = strtrim(options.mark);

% Name for the steady-state subdatabase. Must not collide with existing
% fields.
ssName = 'ss';
while isfield(data,ssName)
    ssName = [ssName,'_'];
end

if isa(options.sstate,'model')
    data.(ssName) = get(options.sstate,'sstateLevel');
else
    data.(ssName) = options.sstate;
end

%**************************************************************************

% Read contents definition file.
gd = readcdf_(cdfname,ssName);

hfig = [];
hax = {};
hline = {};
htit = [];
if isempty(gd)
    return
end

% Count number of panels on each page.
page = 0;
count = 1;
npanel = [];
while count <= length(gd)
    switch gd(count).tag
        case '!++'
            page = page + 1;
            npanel(page) = 0;
        case {'!--','!::','!**','!II'}
            npanel(page) = npanel(page) + 1;
    end
    count = count + 1;
end

sub = 'auto';
pos = 1;
count = 1;
page = 0;
plotdb = struct();
for i = 1 : length(gd)
    switch gd(i).tag
        case '#'
            % Change subplot division.
            sub = strtrim(gd(i).title);
        case '!++'
            % New figure.
            hfig(end+1) = figure('selectionType','open');
            orient('landscape');
            hax{end+1} = [];
            hline{end+1} = {};
            if ~isempty(gd(i).title)
                grfun.ftitle(hfig(end),gd(i).title);
            end
            pos = 1;
            page = page + 1;
            [nrow,ncol] = getsubplot_(sub,npanel(page));
        case {'!**'}
            % Skip current subplot position.
            pos = pos + 1;
        case {'!--','!::','!II'}
            % New panel.
            % Draw a line (!--), bar (!::), or errorbar (!II) graph.
            hax{end}(end+1) = subplot(nrow,ncol,pos);
            set(hax{end}(end),'activePositionProperty','position');
            [tmpformula,tmplegend] = ...
                strfun.charlist2cellstr(gd(i).body,'\n');
            nformula = length(tmpformula);
            x = cell([1,nformula]);
            [x{:}] = dbeval(data,tmpformula{:});
            if ~isinf(options.round) && ~isnan(options.round)
                for ix = 1 : length(x)
                    if istseries(x{ix})
                        x{ix} = round(x{ix},options.round);
                    elseif isnumeric(x{ix})
                        factor = 10^options.round;
                        x{ix} = round(x{ix}*factor)/factor;
                    end
                end
            end
            Legend = createLegend_();
            try
                [hline{end}{end+1},tmprange,tmpdata] = ...
                    plot_(hax{end}(end),range,x,gd(i).tag,Legend, ...
                    options,varargin{:});
            catch me
                warning('iris:qplot',...
                    'Error plotting %s.\n\tMatlab says: %s',...
                    gd(i).body,me.message);
            end
            tmptitle = '';
            if ~isempty(gd(i).title)
                tempHandle = grfun.title(gd(i).title);
                if ~isempty(tempHandle)
                    htit(end+1) = tempHandle;
                end
            end
            % Create a name for the entry in the output database based
            % on the (user-supplied) prefix and the current panel's
            % name. Substitute '_' for any [^\w]. If not a valid Matlab
            % name, replace with "Panel#".
            prefix = sprintf(options.prefix,count);
            if nargout > 4
                tmpname = [prefix,regexprep(tmptitle,'[^\w]+','_')];
                if ~isvarname(tmpname)
                    tmpname = sprintf('Panel%g',count);
                end
                plotdb.(tmpname) = tseries(tmprange,tmpdata,options.mark);
            end
            pos = pos + 1;
            count = count + 1;
    end
end

if ~isempty(options.style)
    qstyle(options.style,hfig);
end

if ~isempty(options.clear)
    h = [hax{:}];
    h = h(options.clear);
    for ih = h(:).'
        cla(ih);
        set(ih, ...
            'xTickLabel','','xTickLabelMode','manual', ...
            'yTickLabel','','yTickLabelMode','manual', ...
            'xgrid','off','ygrid','off');
        delete(get(ih,'title'));
    end
end

if options.drawnow
    drawnow();
end


% @ *******************************************************************
    function Legend = createLegend_()
        % Splice legend and marks.
        Legend = {};
        for j = 1 : length(x)
            for k = 1 : size(x{j},2)
                Legend{end+1} = '';
                if length(tmplegend) >= j
                    Legend{end} = [Legend{end},tmplegend{j}];
                end
                if length(options.mark) >= k
                    Legend{end} = [Legend{end},options.mark{k}];
                end
            end
        end
    end
% @ createLegend_().

end

% Subfunctions follow.

% $ ***********************************************************************
function [nrow,ncol] = getsubplot_(sub,npanel)
if ~strcmpi(sub,'auto')
    tmp = sscanf(sub,'%gx%g');
    if isnumeric(tmp) && length(tmp) == 2 && ~any(isnan(tmp))
        nrow = tmp(1);
        ncol = tmp(2);
    else
        sub = 'auto';
    end
end
if strcmpi(sub,'auto')
    x = ceil(sqrt(npanel));
    if x*(x-1) >= npanel
        nrow = x;
        ncol = x-1;
    else
        nrow = x;
        ncol = x;
    end
end
end
% $ getsubplot_().

% $ ***********************************************************************
function [h,range,data] = plot_(hax,range,x,tag,Legend,options,varargin)

switch tag
    case '!--' % Line graph.
        data = [x{:}];
        if istseries(data)
            [h,range,data] = plot(range,data,varargin{:});
        else
            h = plot(range,data,varargin{:});
        end
    case '!::' % Bar graph.
        data = [x{:}];
        if istseries(data)
            [h,range,data] = bar(range,[x{:}],varargin{:});
        else
            h = plot(range,data,varargin{:});
        end
    case '!II' % Errorbar graph.
        [h1,h2,link,range,data] = errorbar(range,x{:},varargin{:});
        h = [h1;h2];
end

if options.tight
    grfun.yaxistight(hax);
end

if options.grid
    grid('on');
end

if options.addclick
    grfun.clicktocopy(hax);
end

% Display legend if there is at least one non-empty entry.
if any(~cellfun(@isempty,Legend))
    legend(Legend{:},'Location','Best');
end

if options.zeroline
    grfun.zeroline(hax);
end

if ~isempty(options.highlight)
    grfun.highlight(hax,options.highlight);
end

if ~isempty(options.vline)
    grfun.vline(hax,options.vline);
end

end
% $ plot_().