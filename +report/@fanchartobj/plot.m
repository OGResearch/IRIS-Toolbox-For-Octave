function Leg = plot(This,Ax)
% plot  [Not a public function] Plot fanchart object.
%
% Backend IRIS class.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team & Sergey Plotnikov.

%--------------------------------------------------------------------------

try
    isequaln(0,0);
    isequalnFunc = @isequaln;
catch
    isequalnFunc = @isequalwithequalnans;
end

% Create the line plot first using the parent's method.
[LegLin,h,time,cData,grid] = plot@report.seriesobj(This,Ax);
grid = grid(:);
stdata = This.std(time);
[probdata,ixSort] = sort(This.prob);
nint = size(probdata,1);
nextplot = get(Ax,'nextPlot');
set(Ax,'nextPlot','add');
pt = nan(1,nint);
stdata = stdata.*This.options.factor;
asym = This.options.asym;
if istseries(asym)
    asym = asym(time);
    asym(isnan(asym)) = 1;
end
lstData = stdata.*(2./(1 + asym));
hstData = stdata.*(2.*asym./(1+asym));


lgd = This.options.fanlegend;
if iscell(lgd)
    if numel(lgd) < length(probdata)
        for i = numel(lgd)+1:length(probdata)
            lgd{i} = sprintf('%g%%',100*This.prop(i));
        end
    end
    lgd = lgd(ixSort);
end
Leg = cell(1,nint);
legEntToDel = [];

% Specify z-axis positions of fanchart bands
zPosRange = linspace(-1,-2,nint+2);
zPosRange = zPosRange(2:end-1);

for i = 1 : nint
    whi = probdata(i);
    lData = sqrt(2)*erfcinv(probdata(i)+1)*lstData;
    hData = -sqrt(2)*erfcinv(probdata(i)+1)*hstData;
    vData = [lData;flipud(hData)];
    vData = vData + [cData;flipud(cData)];
    zPos = zPosRange(i)*ones(size(vData));
    pt(i) = patch([grid;flipud(grid)],vData,zPos,'white');
    lineCol = get(h,'color');
    faceCol = whi*[1,1,1] + (1-whi)*lineCol;
    if This.options.exclude(min([i,end]))
        faceCol = 'none';
    end
    set(pt(i),'faceColor',faceCol, ...
        'edgeColor','none', ...
        'lineStyle','-', ...
        'tag','fanchart', ...
        'userData', whi);
    if isequal(lgd,Inf)
        if This.options.exclude(min([i,end]))
            grfun.excludefromlegend(pt(i));
            legEntToDel = [legEntToDel,i];
        else
            Leg{i} = sprintf('%g%%',100*whi);
        end
    elseif iscell(lgd)
        if ischar(lgd{i}) && ~This.options.exclude(min([i,end]))
            Leg{i} = lgd{i};
        elseif isnan(lgd{i}) || This.options.exclude(min([i,end]))
            grfun.excludefromlegend(pt(i));
            legEntToDel = [legEntToDel,i];
        end
    end
end

% Remove legend entries of bands which have been excluded from legend
Leg(legEntToDel) = [];

% Make sure zLim includes zPosRange
zLim = get(Ax,'zLim');
zLim(1) = min([zLim(1),zPosRange]);
zLim(2) = max(zLim(2),0);
set(Ax,'zLim',zLim);

% Remove all fanchart entries
if isequalnFunc(This.options.fanlegend,NaN)
    grfun.excludefromlegend(pt(:));
    Leg(1:nint) = [];
end

% Combine line and fanchart legend entried
Leg = [LegLin, Leg];

set(Ax,'nextPlot',nextplot);

end