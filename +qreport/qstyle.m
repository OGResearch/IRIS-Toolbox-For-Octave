function qstyle(GS,H,varargin)
% qstyle  Apply styles to graphics object and its descandants.
%
% Syntax
% =======
%
%     qstyle(H,S,...)
%
% Input arguments
% ================
%
% * `H` [ numeric ] - Handle to a figure or axes object that will be styled
% together with its descandants (unless `'cascade='` is false).
%
% * `S` [ struct ] - Struct each field of which refers to an
% object-dot-property; the value of the field will be applied to the the
% respective property of the respective object; see below the list of
% graphics objects allowed.
%
% Options
% ========
%
% * `'cascade='` [ *`true`* | `false` ] - Cascade through all descendants of the
% object `H`; if false only the object `H` itself will be styled.
%
% * `'warning='` [ *`true`* | `false` ] - Display warnings produced by this
% function.
%
% Description
% ============
%
% The style structure, `S`, is constructed of any number of nested
% object-property fields:
%
%     S.object.property = value;
%
% The following is the list of standard Matlab grahics objects the
% top-level fields can refer to:
%
% * `figure`
% * `axes`
% * `title`
% * `xlabel`
% * `ylabel`
% * `zlabel`
% * `line`
% * `bar`
% * `patch`
% * `text`
%
% Special object names
% ---------------------
%
% In addition to standard Matlab graphics object names, you can also refer
% to the following special instances of objects created by IRIS functions:
%
% * `rhsaxes` (an RHS axes object created by `plotyy`)
% * `legend` (represented by an axes object);
% * `plotpred` (line objects with prediction data created by `plotpred`);
% * `highlight` (a patch object created by `highlight`);
% * `highlightcaption` (a text object created by `highlight`);
% * `vline` (a patch object created by `vline`);
% * `vlinecaption` (a text object created by `vline`);
% * `zeroline` (a line object created by `zeroline`).
%
% The property used as the second-level field is simply any regular Matlab
% property of the respective object (see Matlab help on graphics).
%
% The value assigned to a particular property can be either of the
% following:
%
% * a single proper valid value (i.e. a value you would be able to assign
% using the standard Matlab `set` function);
%
% * a cell array of multiple different values that will be assigned to the
% objects of the same type in order of their creation;
%
% * a text string starting with a double exclamation point, `!!`, followed
% by Matlab commands. The commands are expected to eventually create a
% variable named `SET` whose value will then assigned to the respective
% property. The commands have access to variable `H`, a handle to the
% current object.
%
% Setting font size
% ------------------
%
% Font size (in objects like axes, title, etc.) can be set to either a
% numeric scalar (which is the default Matlab behavior) or a character
% string describing a numerical value followed by a percent sign, such as
% `'150%'`. In that case, the font size will be set to the corresponding
% percentage of the current size.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Parse options.
opt = passvalopt('qreport.qstyle',varargin{:});

% Swap style struct and graphic handle if needed.
if all(ishghandle(GS))
    [GS,H] = deal(H,GS);
end

%--------------------------------------------------------------------------

if ischar(GS)
    % Called with a file name.
    % Remove extension.
    [fpath,ftitle] = fileparts(GS);
    GS = xxRunGsf(fullfile(fpath,ftitle),@run);
elseif iscellstr(GS) && length(GS) == 1
    % Called directly with commands.
    GS = strtrim(GS{1});
    GS = strrep(GS,'"','''');
    if ~isempty(GS)
        if GS(end) ~= ';'
            GS(end+1) = ';';
        end
        GS = xxRunGsf(GS,@eval);
    end
end

for i = H(:).'
    if ~ishghandle(i)
        continue
    end
    switch get(i,'type')
        case 'figure'
            xxFigure(i,GS,opt);
        case {'axes','legend'} % HG2 legends are not axes objects.
            xxAxes(i,GS,opt);
        otherwise
            utils.error('qreport', ...
                'QSTYLE can be applied only to figures or axes.');
    end
end

end


% Subfunctions...


%**************************************************************************


function d = xxRunGsf(Gsf,Func)
% Run graphic style file and create graphic style database.
axes = [];
figure = [];
label = [];
line = [];
title = [];
Func(Gsf);
d = struct();
d.axes = axes;
d.figure = figure;
d.label = label;
d.line = line;
d.title = title;
end % xxRunGsf()


%**************************************************************************


function xxApplyTo(H,D,Field,Opt)

H = findobj(H,'flat','-not','userData','excludeFromStyle');
if isempty(H)
    return
end

% Make fieldnames in the qstyle struct case-insensitive.
list = fieldnames(D);
index = strcmpi(Field,list);
if ~any(index)
    return
end
D = D.(list{index});

nh = length(H);
list = fieldnames(D);
for i = 1 : length(list)
    x = D.(list{i});
    if ~iscell(x)
        x = {x};
    end
    nx = numel(x);
    name = regexprep(list{i},'_*$','');
    for j = 1 : nh
        value = x{1+rem(j-1+Opt.offset,nx)};
        try
            if ischar(value) && strncmp(strtrim(value),'!!',2)
                % Execture style processor.
                value = grfun.mystyleprocessor(H(j),value);
            end
            set(H(j),name,value);
        catch Error
            flag = xxExceptions(H(j),name,value);
            if ~flag && Opt.warning
                warning('iris:qreport',...
                    ['Error setting %s property ''%s''.\n', ...
                    '\tMatlab says: %s'],...
                    Field,name,Error.message);
            end
        end
    end
end

end % xxApplyTo()


%**************************************************************************


function xxFigure(H,D,Opt)
if isempty(H)
    return
end
H = H(:)';
xxApplyTo(H,D,'figure',Opt);
if Opt.cascade
    for i = H
        %{
            % Find all children with titles, and style the titles.
            obj = findobj(i,'-property','title');
            xxtitle(obj(:).',d,options);
        %}
        % Find all axes.
        obj = findobj(i,'type','axes');
        xxAxes(obj(:).',D,Opt);
    end
end
end % xxFigure()


%**************************************************************************


function xxAxes(H,D,Opt)
% xxAxes  Style axes objects and their associates.

if isempty(H)
    return
end

% Find all legend axes, and apply the legend style to them. Do not
% cascade through the legend axes.
lg = findobj(H,'flat','Tag','legend');
xxApplyTo(lg,D,'legend',Opt);
% Find the remaining regular axes. Cascade through them if requested by
% the user.
H = findobj(H,'flat','-not','Tag','legend');
H = H(:).';
xxApplyTo(H(end:-1:1),D,'axes',Opt);

% First, objects that can only have one instance within each parent
% axes object. These are considered part of the axes and are styled
% even if cascade is false.
rhsPeer = [];
for iH = H
    % Check if this axes has a plotyy peer.
    iPeer = getappdata(iH,'graphicsPlotyyPeer');
    if ~isempty(iPeer) && strcmp(get(iH,'yAxisLocation'),'right')
        % The current `iH` is an RHS peer. It will be styled first together with
        % its LHS peer, and then separately by using an `rhsaxes` field if it
        % exist.
        rhsPeer(end+1) = iH; %#ok<AGROW>
        continue
    end
    
    jH = [iPeer,iH];
    xxApplyTo(jH,D,'axes',Opt);
    
    % Associates of axes objects.
    xLabelObj = get(iH,'xlabel');
    yLabelObj = get(iH,'ylabel');
    zLabelObj = get(iH,'zlabel');
    titleObj = get(iH,'title');
    if ~isempty(iPeer)
        xLabelObj(end+1) = get(iPeer,'xLabel'); %#ok<AGROW>
        yLabelObj(end+1) = get(iPeer,'yLabel'); %#ok<AGROW>
        zLabelObj(end+1) = get(iPeer,'zLabel'); %#ok<AGROW>
        titleObj(end+1) = get(iPeer,'title'); %#ok<AGROW>
    end
    xxApplyTo(xLabelObj,D,'xLabel',Opt);
    xxApplyTo(yLabelObj,D,'yLabel',Opt);
    xxApplyTo(zLabelObj,D,'zLabel',Opt);
    xxApplyTo(titleObj,D,'title',Opt);
    
    if ~Opt.cascade
        continue
    end
    
    % Find handles to all line objects except those created by
    % `zeroline`, `vline`, and the prediction data plotted by
    % `plotpred`.
    lineObj = findobj(jH,'type','line', ...
        '-and','-not','tag','hline', ...
        '-and','-not','tag','zeroline', ...
        '-and','-not','tag','vline', ...
        '-and','-not','tag','plotpred');
    xxApplyTo(lineObj(end:-1:1).',D,'line',Opt);
    
    % Find handles to prediction data lines created by `plotpred`.
    plotPredObj = findobj(jH,'type','line','tag','plotpred');
    xxApplyTo(plotPredObj.',D,'plotpred',Opt);
    
    % Find handles to zerolines and hlines; do not revert the order of handles.
    zeroLineObj = findobj(jH,'type','line','tag','zeroline');
    xxApplyTo(zeroLineObj.',D,'zeroline',Opt);
    hLineObj = findobj(jH,'type','line','tag','hline');
    xxApplyTo(hLineObj.',D,'zeroline',Opt);
    
    % Find handles to vlines. Do not revert the order of handles; vline objects
    % are now patches, not lines any more.
    % vLineObj = findobj(jH,'type','line','tag','vline');
    vLineObj = findobj(jH,'type','patch','tag','vline');
    xxApplyTo(vLineObj.',D,'vline',Opt);
    
    % Bar graphs.
    barObj = findobj(jH,'-property','barWidth');
    xxApplyTo(barObj(end:-1:1).',D,'bar',Opt);
    
    % Stem graphs.
    stemObj = findobj(jH,'type','stem');
    xxApplyTo(stemObj.',D,'stem',Opt);
    
    % Find handles to all patches except highlights and fancharts.
    patchObj = findobj(jH,'type','patch', ...
        '-and','-not','tag','highlight', ...
        '-and','-not','tag','fanchart');
    xxApplyTo(patchObj(end:-1:1).',D,'patch',Opt);
    
    % Find handles to highlights. Do not revert the order of
    % handles.
    highlightObj = findobj(jH,'type','patch','tag','highlight');
    xxApplyTo(highlightObj.',D,'highlight',Opt);
    
    % Find handles to fancharts. Do not revert the order of
    % handles.
    fanchartObj = findobj(jH,'type','patch','tag','fanchart');
    xxApplyTo(fanchartObj.',D,'fanchart',Opt);
    
    % Find handles to all text objects except zeroline captions and
    % highlight captions.
    textObj = findobj(jH,'type','text', ...
        '-and','-not','tag','zeroline-caption', ...
        '-and','-not','tag','vline-caption');
    xxApplyTo(textObj(end:-1:1).',D,'text',Opt);
    
    % Find handles to vline-captions and highlight-captions.
    vLineCaptionObj = findobj(jH,'tag','vline-caption');
    xxApplyTo(vLineCaptionObj(end:-1:1).',D,'vlinecaption',Opt);
    highlightCaptionObj = findobj(jH,'tag','highlight-caption');
    xxApplyTo(highlightCaptionObj(end:-1:1).',D, ...
        'highlightcaption',Opt);
    
end

% Apply the `rhsaxes` field (if it exists) to RHS peers in `plotyy` graphs.
% These have been applied the regular `axes` field in the step above.
for iPeer = rhsPeer
    xxApplyTo(iPeer,D,'rhsaxes',Opt);
end

end % xxAxes()


%**************************************************************************


function Flag = xxExceptions(H,Name,Value)

Flag = true;

if strcmpi(Name,'fontsize') ...
        && ~isempty(Value) && ischar(Value) ...
        && strncmp(fliplr(strtrim(Value)),'%',1)
    Value = sscanf(Value,'%g');
    try
        old = get(H,'fontSize');
        new = old * Value/100;
        set(H,'fontSize',new);
    catch
        Flag = false;
    end
    return
end

hType = get(H,'type');
hTag = get(H,'tag');
switch hType
    case 'axes'
        switch lower(Name)
            case 'yaxislocation'
                if strcmpi(Value,'either')
                    grfun.axisoneitherside(H,'y');
                end
            case 'xaxislocation'
                if strcmpi(Value,'either')
                    grfun.axisoneitherside(H,'x');
                end
            case 'yticklabelformat'
                yTick = get(H,'yTick');
                yTickLabel = cell(size(yTick));
                for i = 1 : length(yTick)
                    yTickLabel{i} = sprintf(Value,yTick(i));
                end
                set(H,'yTickLabel',yTickLabel, ...
                    'yTickMode','manual', ...
                    'yTickLabelMode','manual');
            case 'tight'
                if isequal(Value,true) || isequal(lower(Value),'on')
                    grfun.yaxistight(H);
                    isTseries = getappdata(H,'tseries');
                    if ~isequal(isTseries,true)
                        grfun.xaxistight(H);
                    end
                end
            case 'clicktocopy'
                if isequal(Value,true)
                    grfun.clicktocopy(H);
                end
            otherwise
                Flag = false;
        end
    case 'patch'
        switch lower(Name)
            case 'basecolor'
                if strcmpi(get(H,'tag'),'fanchart')
                    white = get(H,'userData');
                    faceColor = get(H,'faceColor');
                    if ischar(faceColor) && strcmpi(faceColor,'none')
                        grfun.excludefromlegend(H);
                    else
                        faceColor = white*[1,1,1] + (1-white)*Value;
                    end;
                    set(H,'faceColor',faceColor);
                end
            case 'color'
                % Vline objects used to be lines, now they are patches (zero width); see
                % remarks in `grfun.vline`.
                if strcmpi(hTag,'vline')
                    set(H,'edgeColor',Value);
                end
            otherwise
                Flag = false;
        end
end

end % xxExceptions()