function [FF,AA,PDb] = qreport(FileName,D,Range,varargin)
% qreport  [Not a publich function] Quick-report master file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

[opt,varargin] = passvalopt('qreport.qreport',varargin{:});

% Choose default plot function for calls by `dbplot`.
opt = xxPlotFunc(opt);

%--------------------------------------------------------------------------

if ~isempty(opt.saveas)
    [~,~,opt.saveasformat] = fileparts(opt.saveas);
end

% Create qreport struct.
Q = xxInp2Struct(FileName,opt);

% Resolve auto subplots.
Q = xxResolveAutoSubplot(Q);

% Evaluate expressions.
Q = xxEvalExpr(Q,D,opt);

% Replace empty titles with eval strings.
Q = xxEmptyTitles(Q,opt);

% Create figures and output database (if requested).
opt.outputdata = nargout > 2 ...
    || (~isempty(opt.saveas) || strcmpi(opt.saveasformat,'.csv'));
[FF,AA,PDb,FTit] = xxRender(Q,Range,opt,varargin{:});

% Apply ex-post options.
xxPostMortem(FF,AA,PDb,FTit,opt);

if opt.pagenumber
    xxPageNumber(FF);
end

if ~isempty(opt.saveas)
    xxSaveAs(FF,PDb,opt);
end

end

% Subfunctions.

%**************************************************************************
function Q = xxInp2Struct(Inp,Opt)

if isa(Inp,'function_handle')
    % Allow function handles.
    Inp = char(Inp);
end

if ischar(Inp)
    % Pre-parse the q-file.
    p = preparser(Inp, ...
        'removecomments=',{{'%{','%}'},'(?<!\\)%'}, ...
        'clone=',Opt.clone);

    % Put labels back into the code.
    c = preparser.labelsback(p.code,p.labels);
    
    % Replace escaped % signs.
    c = strrep(c,'\%','%');
    
    % Replace single quotes with double quotes.
    c = strrep(c,'''','"');
else
    c = Inp;
    if ~isempty(Opt.clone)
        [c,labels] = preparser.protectlabels(c);
        c = preparser.myclone(c,Opt.clone);
        c = preparser.labelsback(c,labels);
    end
end

Q = {};
first = true;
while ~isempty(c)
    [c,q] = xxGetNext(c,Opt);
    if strcmp(q.tag,'#')
        Opt.subplot = doGetSubPlot(q.caption);
        continue
    end
    % Add a new figure if there's none at the beginning of the qreport.
    if first && ~strcmp(q.tag,'!++')
        q0 = struct();
        q0.tag = '!++';
        q0.caption = '';
        q0.subplot = Opt.subplot;
        q0.children = {};
        Q{end+1} = q0; %#ok<AGROW>
    end
    if strcmp(q.tag,'!++')
        Q{end+1} = q; %#ok<AGROW>
    else
        Q{end}.children{end+1} = q;
    end
    first = false;
end

    function X = doGetSubPlot(C)
        % doGetSubPlot  Convert subplot string to vector or 'auto'.
        X = sscanf(C,'%gx%g');
        if isnumeric(X) && length(X) == 2 ...
                && all(~isnan(X) & X > 0 & X == round(X))
            X = X(:).';
        else
            X = 'auto';
        end
    end

end % xxInp2Struct().

%**************************************************************************
function [Inp,S] = xxGetNext(Inp,Opt)

S = struct();
S.tag = '';
S.caption = '';

if isempty(Inp)
    return
end

if ischar(Inp)
    % Replace old syntax !** with !..
    Inp = strrep(Inp,'!**','!..');
    % Q-file code from `qplot`.
    tags = '#|!\+\+|!\-\-|!::|!ii|!II|!\.\.|!\^\^';
    [tok,e] = regexp(Inp,['(',tags,')(\^?)(.*?)(?=',tags,'|$)'], ...
        'tokens','end','once');
    if ~isempty(tok)
        S.tag = tok{1};
        doTransform = ~strncmp(tok{2},'^',1);
        tok = regexp(tok{3},'([^\n]*)(.*)','once','tokens');
        S.caption = tok{1};
        body = tok{2};
        Inp = Inp(e+1:end);
    end
elseif iscellstr(Inp)
    % Cellstr from `dbplot`.
    c = strtrim(Inp{1});
    Inp = Inp(2:end);
    if ~isempty(c)
        S.tag = Opt.plotfunc;
        doTransform = ~strncmp(c,'^',1);
        if ~doTransform
            c = c(2:end);
        end
        [body,S.caption] = preparser.labeledexpr(c);
    else
        S.tag = '!..';
        S.caption = '';
        S.eval = {};
        S.legend = {};
        S.tansform = [];
        return
    end
else
    return
end

% Title.
S.caption = strtrim(S.caption);

if strcmp(S.tag,'#')
    return
end

if strcmp(S.tag,'!++')
    S.subplot = Opt.subplot;
    S.children = {};
    return
end

% Expressions and legends.
[S.eval,S.legend] = xxReadBody(body);

S.transform = [];
if doTransform && ~strcmp(S.tag,'!++')
    S.transform = Opt.transform;
end

end % xxGetNext().

%**************************************************************************
function [Eval,Leg] = xxReadBody(C)
C = strtrim(C);
C = strfun.strrepoutside(C,',',sprintf('\n'),'()','[]','{}');
C = strfun.strrepoutside(C,' & ',sprintf('\n'),'()','[]','{}');
lines = regexp(C,'[^\n]*','match');
[Eval,Leg] = preparser.labeledexpr(lines);
end % xxReadBody().

%**************************************************************************
function Q = xxResolveAutoSubplot(Q)
nFig = length(Q);
for i = 1 : nFig
    if strcmp(Q{i}.subplot,'auto')
        Q{i}.subplot = utils.autosubplot(length(Q{i}.children));
    end
end
end % xxResolveAutoSubplot().

%**************************************************************************
function Q = xxEvalExpr(Q,D,Opt)

doround = ~isinf(Opt.round) && ~isnan(Opt.round);
for i = 1 : length(Q)
    for j = 1 : length(Q{i}.children)
        ch = Q{i}.children{j};
        if strcmp(ch.tag,'!..')
            continue
        end
        neval = length(ch.eval);
        series = cell(1,neval);
        [series{:}] = dbeval(D,Opt.sstate,ch.eval{:});
        if isa(ch.transform,'function_handle')
            for k = 1 : length(series)
                series{k} = ch.transform(series{k});
            end
        end
        if doround
            series = myround(series);
        end
        Q{i}.children{j}.series = series;
    end
end

    function x = myround(x)
        for ii = 1 : length(x)
            if isa(x{ii},'tseries')
                x{ii} = round(x{ii},Opt.round);
            elseif isnumeric(x{ii})
                factor = 10^Opt.round;
                x{ii} = round(x{ii}*factor)/factor;
            end
        end
    end

end % xxEvalExpr().

%**************************************************************************
function Q = xxEmptyTitles(Q,Opt)

for i = 1 : length(Q)
    for j = 1 : length(Q{i}.children)
        ch = Q{i}.children{j};
        if strcmp(ch.tag,'!..')
            continue
        end
        if isempty(ch.caption)
            k = i*j;
            if iscellstr(Opt.caption) ...
                    && length(Opt.caption) >= k && ~isempty(Opt.caption{k})
                ch.caption = Opt.caption{k};
            elseif isa(Opt.caption,'function_handle')
                ch.caption = Opt.caption;
            else
                ch.caption = [sprintf('%s & ',ch.eval{1:end-1}),ch.eval{end}];
                if isa(ch.transform,'function_handle')
                    c = char(ch.transform);
                    c = regexprep(c,'^@\(.*?\)','','once');
                    ch.caption = [ch.caption,', ',c];
                end
            end
        end
        Q{i}.children{j} = ch;
    end
end

end
% xxEmptyTitles().

%**************************************************************************
function [FF,AA,PlotDb,FTit] = xxRender(Q,Range,Opt,varargin)

FF = [];
AA = {};
PlotDb = struct();

count = 1;
nRow = NaN;
nCol = NaN;
pos = NaN;
FTit = {};
for i = 1 : length(Q)
    % New figure.
    doNewFigure();
    
    nchild = length(Q{i}.children);
    for j = 1 : nchild
        tag = Q{i}.children{j}.tag;
        % If `'overflow='` is true we automatically open a new figure when the
        % subplot count overflows; this is the default behaviour for `dbplot`.
        % Otherwise, an error occurs; this is the default behaviour for `qplot`.
        if pos > nRow*nCol && Opt.overflow
            % Open a new figure and reset the subplot position `pos`.
            doNewFigure();
        end
        switch tag
            case {'!..'}
                % Blank space, do not count.
                pos = pos + 1;
            otherwise
                % New panel/subplot.
                doNewPanel();
                
                x = Q{i}.children{j}.series;
                leg = Q{i}.children{j}.legend;
                
                % Get title; it can be either a string or a function handle that will be
                % applied to the plotted tseries object.
                tit = xxGetTitle(Q{i}.children{j}.caption,x);
                
                finalLegend = doCreateLegend();
                % Create an entry for the current panel in the output database. Do not
                % if plotting the panel fails.
                addToOutput = true;
                try
                    [range,data] = ...
                        xxPlot(tag,aa,Range,x,finalLegend,Opt,varargin{:});
                catch me
                    addToOutput = true;
                    utils.warning('qreport',...
                        'Error plotting ''%s''.\n\tMatlab says: %s',...
                        Q{i}.children{j}.caption,me.message);
                end
                if ~isempty(tit)
                    grfun.title(tit,'interpreter=',Opt.interpreter);
                end
                % Create a name for the entry in the output database based
                % on the (user-supplied) prefix and the current panel's
                % name. Substitute '_' for any [^\w]. If not a valid Matlab
                % name, replace with "Panel#".
                if Opt.outputdata && addToOutput
                    tmpName = [sprintf(Opt.prefix,count), ...
                        regexprep(tit,'[^\w]+','_')];
                    if ~isvarname(tmpName)
                        tmpName = sprintf('Panel%g',count);
                    end
                    try
                        PlotDb.(tmpName) = tseries(range,data,finalLegend);
                    catch %#ok<CTCH>
                        PlotDb.(tmpName) = NaN;
                    end
                end
                if ~isempty(Opt.xlabel)
                    xlabel(Opt.xlabel);
                end
                if ~isempty(Opt.ylabel)
                    ylabel(Opt.ylabel);
                end
                count = count + 1;
                pos = pos + 1;
        end
    end
end

    function FinalLeg = doCreateLegend()
        % Splice legend and marks.
        FinalLeg = {};
        for ii = 1 : length(x)
            for jj = 1 : size(x{ii},2)
                c = '';
                if ii <= length(leg)
                    c = [c,leg{ii}]; %#ok<AGROW>
                end
                if jj <= length(Opt.mark)
                    c = [c,Opt.mark{jj}]; %#ok<AGROW>
                end
                FinalLeg{end+1} = c; %#ok<AGROW>
            end
        end
    end % doCreateLegend().

    function doNewFigure()
        ff = figure('selectionType','open');
        FF = [FF,ff];
        orient('landscape');
        AA{end+1} = [];
        nRow = Q{i}.subplot(1);
        nCol = Q{i}.subplot(2);
        pos = 1;
        FTit{end+1} = Q{i}.caption;
    end % doNewFigure().

    function doNewPanel()
        aa = subplot(nRow,nCol,pos);
        AA{i} = [AA{i},aa];
        set(aa,'activePositionProperty','position');
    end % doNewPanel().

end
% xxRender().

%**************************************************************************
function [Range,Data] = xxPlot(Tag,AA,Range,X,Leg,Opt,varargin)

isXGrid = Opt.grid;
isYGrid = Opt.grid;

switch Tag
    case '!--' % Line graph.
        Data = [X{:}];
        if istseries(Data)
            [h,Range,Data] = plot(AA,Range,Data,varargin{:}); %#ok<*ASGLU>
        elseif ~isempty(Data)
            plot(Range,Data,varargin{:});
            %axis tight;
        else
            % Do nothing.
        end
    case '!::' % Bar graph.
        Data = [X{:}];
        if istseries(Data)
            [h,Range,Data] = bar(Range,[X{:}],varargin{:});
        else
            bar(Range,Data,varargin{:});
        end
    case '!ii' % Stem graph
        Data = [X{:}];
        if istseries(Data)
            [h,Range,Data] = stem(Range,[X{:}],varargin{:});
        else
            stem(Range,Data,varargin{:});
        end
    case '!II' % Error bar graph.
        [h1,h2,Range,Data] = errorbar(Range,X{:},varargin{:});
    case '!>>' % Prediction plot.
        [h1,h2,h3,Range,Data] = plotpred(Range,X{:},varargin{:});
    case '!^^' % Histogram.
        Data = [X{:}];
        Data = Data(Range,:);
        [count,pos] = hist(Data);
        h = bar(pos,count,'barWidth',0.8); %#ok<NASGU>
        isXGrid = false;
    case '!??' % Plotcmp.
        [AA,ll,rr,Range,Data] = plotcmp(Range,[X{:}],varargin{:});
end

if Opt.tight
    isTseries = getappdata(AA);
    if isequal(isTseries,true)
        grfun.yaxistight(AA);
    else
        axis(AA,'tight');
    end
end

if isXGrid
    set(AA,'xgrid','on');
end

if isYGrid
    set(AA,'ygrid','on');
end

if Opt.addclick
    grfun.clicktocopy(AA);
end

% Display legend if there is at least one non-empty entry.
if any(~cellfun(@isempty,Leg))
    legend(Leg{:},'Location','Best');
end

if Opt.zeroline
    grfun.zeroline(AA);
end

if ~isempty(Opt.highlight)
    grfun.highlight(AA,Opt.highlight);
end

if ~isempty(Opt.vline)
    grfun.vline(AA,Opt.vline);
end

end % xxPlot().

%**************************************************************************
function xxPostMortem(FF,AA,PlotDb,FTit,Opt) %#ok<INUSL>

if ~isempty(Opt.style)
    qstyle(Opt.style,FF);
end

if Opt.addclick
    grfun.clicktocopy([AA{:}]);
end

if ~isempty(Opt.clear)
    h = [AA{:}];
    h = h(Opt.clear);
    for ih = h(:).'
        cla(ih);
        set(ih, ...
            'xTickLabel','','xTickLabelMode','manual', ...
            'yTickLabel','','yTickLabelMode','manual', ...
            'xgrid','off','ygrid','off');
        delete(get(ih,'title'));
    end
end

for i = 1 : length(FTit)
    % Figure titles must be created last because the `subplot` commands clear
    % figures.
    if ~isempty(FTit{i})
        grfun.ftitle(FF(i),FTit{i});
    end
end

if Opt.drawnow
    drawnow();
end

end % xxPostMortem().

%**************************************************************************
function xxPageNumber(FF)

nPage = length(FF);
count = 0;
for f = FF(:).'
    figure(f);
    count = count + 1;
    grfun.ftitle({'','',sprintf('%g/%g',count,nPage)});
end

end % xxPageNumber().

%**************************************************************************
function xxSaveAs(FF,PLOTDB,Opt)

if strcmpi(Opt.saveasformat,'.csv')
    dbsave(PLOTDB,Opt.saveas,Inf,Opt.dbsave{:});
    return
end

if any(strcmpi(Opt.saveasformat,{'.pdf'}))
    [fPath,fTit] = fileparts(Opt.saveas);
    psfile = fullfile([fTit,'.ps']);
    if exist(psfile,'file')
        delete(psfile);
    end
    for f = FF(:).'
        figure(f);
        orient('landscape');
        print('-dpsc','-append',psfile);
    end
    latex.ps2pdf(psfile);
    delete(psfile);
end

end % xxSaveAs().

%**************************************************************************
function Opt = xxPlotFunc(Opt)
% xxPlotFunc  Convert the `'plotFunc='` option in `dbplot` to the corresponding tag.

switch char(Opt.plotfunc)
    case 'plot'
        Opt.plotfunc = '!--';
    case 'bar'
        Opt.plotfunc = '!::';
    case 'errorbar'
        Opt.plotfunc = '!II';
    case 'stem'
        Opt.plotfunc = '!ii';
    case 'hist'
        Opt.plotfunc = '!^^';
    case 'plotpred'
        Opt.plotfunc = '!>>';
    case 'plotcmp'
        Opt.plotfunc = '!??';
    otherwise
        % Error bar graphs are not available in `dbplot`.
        Opt.plotfunc = '!--';
end

end % xxPlotFunc().

%**************************************************************************
function Tit = xxGetTitle(TitleOpt,X)
% xxgettitle  Title is either a user-supplied string or a function handle
% that will be applied to the plotted tseries object.

invalid = '???';
if isa(TitleOpt,'function_handle')
    try
        Tit = TitleOpt([X{:}]);
        if iscellstr(Tit)
            Tit = sprintf('%s,',Tit{:});
            Tit(end) = '';
        end
        if ~ischar(Tit)
            Tit = invalid;
        end
    catch %#ok<CTCH>
        Tit = invalid;
    end
elseif ischar(TitleOpt)
    Tit = TitleOpt;
else
    Tit = invalid;
end

end % xxGetTitle().