function h = fanchart(h0,bands,varargin)

if ~strcmp(get(h0,'type'),'line')
   error('Incorrect input handle.');
end

xdata = get(h0,'xdata');
ydata = get(h0,'ydata');
ndata = length(xdata);

if istseries(bands)
  range = gettimescale(h0);
  bands = bands(range)';
else
  if length(bands) ~= ndata
     error('Incorrect length of fanchart data.');
  end
  if size(bands,2) < size(bands,1)
     bands = transpose(bands);
  end
end

nbands = size(bands,1);

grade = (2 : nbands+1) / (nbands+2);

nextplot = get(gca,'nextplot');
ylimmode = get(gca,'ylimmode');
set(gca,'nextplot','add','ylimmode','auto','layer','top');
count = 0;
for i = nbands : -1 : 1
  index = ~isnan(bands(i,:));
  if any(index)
    x = xdata(index);
    x = [x,x(end:-1:1)];
    y = ydata(index) + bands(i,index);
    y = [ydata(index),y(end:-1:1)];
    h = fill(x,y,grade(i)*[1,1,1]);
    set(h,'linestyle','none');
    y = ydata(index) - bands(i,index);
    y = [ydata(index),y(end:-1:1)];
    h = fill(x,y,grade(i)*[1,1,1]);
    set(h,'linestyle','none');
    count = count + 2;
  end
end
ch = get(gca,'children');
set(gca,'children',[ch(count+1:end);ch(1:count)]);
set(gca,'nextplot',nextplot,'ylimmode',ylimmode);

end