function LegendEntry = plot(This,Ax)
% plot [Not a public function] Draw report/band object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if any(strcmpi(This.options.plottype,{'patch','line'}))
    % Create the line plot first using the parent's method.
    [LegendEntry,h,time,cdata,grid] = plot@report.seriesobj(This,Ax);
    doPatch();
else
    LegendEntry = {};
    doErrorBars();
end

% Nested functions.

%**************************************************************************
    function doPatch()    
        grid = grid(:);
        lData = This.low{1}(time);
        hData = This.high{1}(time);
        lData = lData(:,:);
        hData = hData(:,:);
        nx = max([size(cdata,2),size(lData,2),size(hData,2)]);
        nextPlot = get(Ax,'nextPlot');
        set(Ax,'nextPlot','add');
        pt = nan(1,nx);
        
        for i = 1 : nx
            white = This.options.white(min(i,end));
            % Retrieve current set of data.
            iCData = cdata(:,min(i,end));
            iLData = lData(:,min(i,end));
            if This.options.relative && all(iLData(:) >=0 )
                iLData = -iLData;
            end
            iHData = hData(:,min(i,end));
            % Create x- and y-data for the patch function.
            xData = [grid;flipud(grid)];
            yData = [iLData;flipud(iHData)];
            if This.options.relative
                yData = yData + [iCData;flipud(iCData)];
            end
            % Remove data points where either x-data or y-data is NaN.
            nanindex = isnan(xData) | isnan(yData);
            if all(nanindex)
                continue
            end
            xData = xData(~nanindex);
            yData = yData(~nanindex);
            % Draw patch.
            pt(i) = patch(xData,yData,'white');
            lineCol = get(h(min(i,end)),'color');
            faceCol = white*[1,1,1] + (1-white)*lineCol;
            set(pt(i),'faceColor',faceCol, ...
                'edgeColor','white', ...
                'lineStyle','-', ...
                'tag','background');
        end
        grfun.excludefromlegend(pt);
        set(Ax,'nextPlot',nextPlot);
    end % doPatch().

%**************************************************************************
    function doErrorBars()
        [~,~,~,data] = errorbar(Ax,This.options.range, ...
            This.data{1},This.low{1},This.high{1}, ...
            'relative=',This.options.relative);
        LegendEntry = mylegend(This,size(data,2));
    end % doErrorBars().

end