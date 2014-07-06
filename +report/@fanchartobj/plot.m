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
[Leg,h,time,cData,grid] = plot@report.seriesobj(This,Ax);
grid = grid(:);
stdata = This.std(time);
probdata = This.prob;
nint = size(probdata,1);
nextplot = get(Ax,'nextPlot');
set(Ax,'nextPlot','add');
pt = nan(1,nint);
stdata = stdata.*This.options.factor;
asym = This.options.asym;
if is.tseries(asym)
    asym = asym(time);
    asym(isnan(asym)) = 1;
end
lstData = stdata.*(2./(1 + asym));
hstData = stdata.*(2.*asym./(1+asym));
Leg = [cell(1,nint) Leg];

for i = 1 : nint
    whi = probdata(i);
    % ldata = -norminv(0.5*probdata(i)+0.5)*lstdata;
    lData = sqrt(2)*erfcinv(probdata(i)+1)*lstData;
    % hdata = norminv(0.5*probdata(i)+0.5)*hstdata;
    hData = -sqrt(2)*erfcinv(probdata(i)+1)*hstData;
    vData = [lData;flipud(hData)];
    vData = vData + [cData;flipud(cData)];
    pt(i) = patch([grid;flipud(grid)],vData,'white');
    % Temporary show excluded from legend (for Octave's way of excluding)
    if ~ismatlab
        grfun.mytrigexcludedfromlegend(Ax,'on');
    end
    ch = get(Ax,'children');
    ch(ch == pt(i)) = [];
    ch(end+1) = pt(i); %#ok<AGROW>
    set(Ax,'children',ch);
    % Hide back excluded from legend (for Octave's way of excluding)
    if ~ismatlab
        grfun.mytrigexcludedfromlegend(Ax,'off');
    end
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
    lgd = This.options.fanlegend;
    if isequal(lgd,Inf)
        if This.options.exclude(min([i,end]))
            grfun.excludefromlegend(pt(i));
            Leg(nint+1-i) = [];
        else
            Leg{nint+1-i} = sprintf('%g%%',100*whi);
        end;
    elseif iscell(lgd)
        if ~all(isnan(lgd{i})) && ~This.options.exclude(min([i,end]))
            Leg{nint+1-i} = lgd{i};
        else
            grfun.excludefromlegend(pt(i));
            Leg(nint+1-i) = [];
        end
    end
end

if isequalnFunc(This.options.fanlegend,NaN)
    grfun.excludefromlegend(pt(:));
    Leg(1:nint) = [];
end

set(Ax,'nextPlot',nextplot);

end