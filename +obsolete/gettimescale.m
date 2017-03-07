function x = gettimescale(h)

if strcmp(get(h,'type'),'line')
  hline = h;
  haxes = get(h,'parent');
else
  haxes = h;
  hline = [];
  ch = get(h,'children');
  for i = ch(:).'
    if strcmp(get(i,'type'),'line')
      hline = i;
      break
    end
  end
end  

if ~strcmp(get(haxes,'tag'),'tseries')
  warning('No time series plotted in graph.');
  return
end

x = get(hline,'xdata');
x = dec2dat(x,get(haxes,'userdata'));

end