function [FF,AA,PDb] = qreport(FileName,D,Range,varargin)
% qreport  [Not a publich function] Quick-report master file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

[opt,varargin] = passvalopt('qreport.qreport',varargin{:});

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
        'removeComments=',{{'%{','%}'},'(?<!\\)%'}, ...
        'clone=',Opt.clone);
    
    % Put labels back in the code, including the quotes.
    c = restore(p.code,p.labels);
    
    % Replace escaped % signs.
    c = strrep(c,'\%','%');
    
    % Replace single quotes with double quotes.
    c = strrep(c,'''','"');
else
    c = Inp;
    if ~isempty(Opt.clone)
        labels = fragileobj(c);
        [c,labels] = protectquotes(c,labels);
        c = preparser.myclone(c,Opt.clone);
        c = restore(c,labels);
    end
end

Q = {};
first = true;
while ~isempty(c)
    [c,q] = xxGetNext(c,Opt);
    if isequal(q.func,'subplot')
        Opt.subplot = doGetSubPlot(q.caption);
        continue
    end
    % Add a new figure if there's none at the beginning of the qreport.
    if first && ~isequal(q.func,'figure')
        q0 = struct();
        q0.func = 'figure';
        q0.caption = '';
        q0.subplot = Opt.subplot;
        q0.children = {};
        Q{end+1} = q0; %#ok<AGROW>
    end
    if isequal(q.func,'figure')
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

end % xxInp2Struct()


%**************************************************************************
function [Inp,S] = xxGetNext(Inp,Opt)

S = struct();
S.func = '';
S.caption = '';
S.isLogDev = false;
S.isLinDev = false;
S.isTransform = true;

if isempty(Inp)
    return
end

if ischar(Inp)
    % Replace old syntax !** with !..
    Inp = strrep(Inp,'!**','!..');
    % Q-file code from `qplot`.
    tags = '#|!\+\+|!\-\-|!::|!ii|!II|!\.\.|!\^\^';
    [tok,e] = regexp(Inp,['(',tags,')([\^#@]{0,2})(.*?)(?=',tags,'|$)'], ...
        'tokens','end','once');
    if ~isempty(tok)
        S.func = xxTag2PlotFunc(tok{1});
        doFlags(tok{2});
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
        S.func = Opt.plotfunc;
        c = doFlags(c);
        [body,S.caption] = preparser.labeledexpr(c);
    else
        S.func = 'empty';
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

if isequal(S.func,'subplot')
    return
end

if isequal(S.func,'figure')
    S.subplot = Opt.subplot;
    S.children = {};
    return
end

% Expressions and legends.
[S.eval,S.legend] = xxReadBody(body);


    function C = doFlags(C)
        while true && ~isempty(C)
            switch C(1)
                case '^'
                    S.isTransform = false;
                case '@'
                    if ~S.isLinDev
                        S.isLogDev = true;
                    end
                case '#'
                    if ~S.isLogDev
                        S.isLinDev = true;
                    end
                case ' '
                    % Do nothing.
                otherwise
                    break
            end
            C(1) = '';
        end
    end % doFlags()


end % xxGetNext()


%**************************************************************************
function [Eval,Leg] = xxReadBody(C)

C = strtrim(C);
C = strfun.strrepoutside(C,',',sprintf('\n'),'()','[]','{}');
C = strfun.strrepoutside(C,' & ',sprintf('\n'),'()','[]','{}');
lines = regexp(C,'[^\n]*','match');
[Eval,Leg] = preparser.labeledexpr(lines);

end % xxReadBody()



%**************************************************************************
function Q = xxResolveAutoSubplot(Q)

nFig = length(Q);
for i = 1 : nFig
    if strcmp(Q{i}.subplot,'auto')
        Q{i}.subplot = utils.autosubplot(length(Q{i}.children));
    end
end

end % xxResolveAutoSubplot()


%**************************************************************************
function Q = xxEvalExpr(Q,D,Opt)

isRound = ~isinf(Opt.round) && ~isnan(Opt.round);

invalidBase = {};
for i = 1 : length(Q)
    for j = 1 : length(Q{i}.children)
        ch = Q{i}.children{j};
        if isequal(ch.func,'empty')
            continue
        end
        nSeries = length(ch.eval);
        series = cell(1,nSeries);
        [series{:}] = dbeval(D,Opt.sstate,ch.eval{:});
        if ch.isTransform
            for k = 1 : nSeries
                % First, calculate deviations, then apply a tranformation function.
                if is.numericscalar(Opt.deviationfrom)
                    t = Opt.deviationfrom;
                    if isa(series{k},'tseries')
                        if ~isfinite(series{k}(t))
                            invalidBase{end+1} = ch.eval{:}; %#ok<AGROW>
                        end
                        series{k} = xxDeviationFrom(series{k}, ...
                            t,ch.isLogDev,ch.isLinDev,Opt.deviationtimes);
                    end
                end
                if isa(Opt.transform,'function_handle')
                    series{k} = Opt.transform(series{k});
                end
            end
        end
        if isRound
            series = myround(series);
        end
        Q{i}.children{j}.series = series;
    end
end

if ~isempty(invalidBase)
    utils.warning('qreport', ...
        ['This expression results in NaN or Inf in base period ',...
        'for calculating deviations: ''%s''.'], ...
        invalidBase{:})
end;

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

end % xxEvalExpr()


%**************************************************************************
function Q = xxEmptyTitles(Q,Opt)

for i = 1 : length(Q)
    for j = 1 : length(Q{i}.children)
        ch = Q{i}.children{j};
        if strcmp(ch.func,'empty')
            continue
        end
        if isempty(ch.caption)
            k = i*j;
            if iscellstr(Opt.caption) ...
                    && length(Opt.caption) >= k ...
                    && ~isempty(Opt.caption{k})
                ch.caption = Opt.caption{k};
            elseif isa(Opt.caption,'function_handle')
                ch.caption = Opt.caption;
            else
                ch.caption = [ ...
                    sprintf('%s & ',ch.eval{1:end-1}), ...
                    ch.eval{end}];
                if ch.isTransform
                    func = '';
                    if is.numericscalar(Opt.deviationfrom)
                        func = [ ...
                            ', Dev from ', ...
                            dat2char(Opt.deviationfrom)];
                    end
                    if isa(Opt.transform,'function_handle')
                        c = func2str(Opt.transform);
                        func = [func,', ', ...
                            regexprep(c,'^@\(.*?\)','','once')]; %#ok<AGROW>
                    end
                    ch.caption = [ch.caption,func];
                end
            end
        end
        Q{i}.children{j} = ch;
    end
end

end % xxEmptyTitles()


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
errorList = {};
unknownList = {};

for i = 1 : length(Q)
    % New figure.
    doNewFigure();
    
    nchild = length(Q{i}.children);
    for j = 1 : nchild
        
        func = Q{i}.children{j}.func;
        
        % If `'overflow='` is true we automatically open a new figure when the
        % subplot count overflows; this is the default behaviour for `dbplot`.
        % Otherwise, an error occurs; this is the default behaviour for `qplot`.
        if pos > nRow*nCol && Opt.overflow
            % Open a new figure and reset the subplot position `pos`.
            doNewFigure();
        end
        
        if isequal(func,'empty')
            pos = pos + 1;
            continue    
        end
        
        % New panel/subplot.
        doNewPanel();
        
        ch = Q{i}.children{j};
        x = ch.series;
        leg = ch.legend;
        
        % Get title; it can be either a string or a function handle that will be
        % applied to the plotted tseries object.
        tit = xxGetTitle(Q{i}.children{j}.caption,x);
        
        finalLegend = doCreateLegend();
        % Create an entry for the current panel in the output database. Do not
        % if plotting the panel fails.
        try
            [range,data,ok] = ...
                xxPlot(func,aa,Range,x,finalLegend,Opt,varargin{:});
            if ~ok
                unknownList{end+1} = Q{i}.children{j}.caption; %#ok<AGROW>
            end
        catch me
            errorList{end+1} = Q{i}.children{j}.caption; %#ok<AGROW>
            errorList{end+1} = me.message; %#ok<AGROW>
        end
        if ~isempty(tit)
            grfun.title(tit,'interpreter=',Opt.interpreter);
        end
        % Create a name for the entry in the output database based on the
        % (user-supplied) prefix and the name of the current panel. Substitute '_'
        % for any [^\w]. If not a valid Matlab name, replace with "Panel#".
        if Opt.outputdata
            plotDbName = tit;
            plotDbName = regexprep(plotDbName,'[ ]*//[ ]*','___');
            plotDbName = regexprep(plotDbName,'[^\w]+','_');
            plotDbName = [ ...
                sprintf(Opt.prefix,count), ...
                plotDbName ...
                ]; %#ok<AGROW>
            if ~isvarname(plotDbName)
                plotDbName = sprintf('Panel%g',count);
            end
            try
                PlotDb.(plotDbName) = ...
                    tseries(range,data,finalLegend);
            catch %#ok<CTCH>
                PlotDb.(plotDbName) = NaN;
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

if ~isempty(errorList)
    utils.warning('qreport:qreport',...
        'Error plotting ''%s''.\n\tMatlab says: %s',...
        errorList{:});
end

if ~isempty(unknownList)
    utils.warning('qreport:qreport', ...
        'Unknown or invalid plot function when plotting ''%s''.', ...
        unknownList{:});
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


end % xxRender()


%**************************************************************************
function [Range,Data,Ok] = xxPlot(Func,AA,Range,X,Leg,Opt,varargin)

isXGrid = Opt.grid;
isYGrid = Opt.grid;

Data = [];
Ok = true;

switch char(Func)
    case {'plot','bar','barcon','stem'}
        Data = [X{:}];
        if is.tseries(Data)
            [h,Range,Data] = Func(Range,Data,varargin{:}); %#ok<*ASGLU>
        elseif ~isempty(Data)
            Func(Range,Data,varargin{:});
        else
            % Do nothing.
        end
    case 'errorbar' % Error bar graph.
        [h1,h2,Range,Data] = errorbar(Range,X{:},varargin{:});
    case 'plotpred' % Prediction plot.
        [h1,h2,h3,Range,Data] = plotpred(Range,X{:},varargin{:});
    case 'hist' % Histogram.
        Data = [X{:}];
        Data = Data(Range,:);
        [count,pos] = hist(Data);
        h = bar(pos,count,'barWidth',0.8); %#ok<NASGU>
        isXGrid = false;
    case 'plotcmp' % Plotcmp.
        [AA,ll,rr,Range,Data] = plotcmp(Range,[X{:}],varargin{:});
    otherwise
        Ok = false;
        return
end

if Opt.tight
    isTseries = getappdata(AA,'tseries');
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

if ~isempty(Opt.vline)
    grfun.vline(AA,Opt.vline,'color=','black');
end

if ~isempty(Opt.highlight)
    grfun.highlight(AA,Opt.highlight);
end

end % xxPlot()


%**************************************************************************
function xxPostMortem(FF,AA,PlotDb,FTit,Opt) %#ok<INUSL>

if ~isempty(Opt.style)
    qstyle(Opt.style,FF);
end

if Opt.addclick
    grfun.clicktocopy([AA{:}]);
end

if ~isempty(Opt.clear)
    aa = [AA{:}];
    aa = aa(Opt.clear);
    if ~isempty(aa)
        tt = get(aa,'title');
        if iscell(tt)
            tt = [tt{:}];
        end
        delete(tt);
        delete(aa);
    end
end

for i = 1 : length(FTit)
    % Figure titles must be created last because the `subplot` commands clear
    % figures.
    if ~isempty(FTit{i})
        grfun.ftitle(FF(i),FTit{i});
    end
end

if Opt.maxfigure
    grfun.maxfigure(FF);
end

if Opt.drawnow
    drawnow();
end

end % xxPostMortem()


%**************************************************************************
function xxPageNumber(FF)

nPage = length(FF);
count = 0;
for f = FF(:).'
    figure(f);
    count = count + 1;
    grfun.ftitle({'','',sprintf('%g/%g',count,nPage)});
end

end % xxPageNumber()


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
        print('-dpsc','-painters','-append',psfile);
    end
    latex.ps2pdf(psfile);
    delete(psfile);
end

end % xxSaveAs()


%**************************************************************************
function Func = xxTag2PlotFunc(Tag)
% xxPlotFunc  Convert the `'plotFunc='` option in `dbplot` to the corresponding tag.

switch Tag
    case '#'
        Func = 'subplot';
    case '!++'
        Func = 'figure';
    case '!..'
        Func = 'empty';
    case '!--'
        Func = @plot;
    case '!::'
        Func = @bar;
    case '!II'
        Func = @errorbar;
    case '!ii'
        Func = @stem;
    case '!^^'
        Func = @hist;
    case '!>>'
        Func = @plotpred;
    case '!??'
        Func = @plotcmp;
    otherwise
        Func = @plot;
end

end % xxPlotFunc()


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

end % xxGetTitle()


%**************************************************************************
function X = xxDeviationFrom(X,T,IsLogDev,IsLinDev,Times)

if IsLinDev
    X = Times*(X - X(T));
elseif IsLogDev
    X = Times*(X./X(T) - 1);
end

end % xxDeviationFrom()