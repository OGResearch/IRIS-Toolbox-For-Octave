try
%% Create artificial series
x = cell(1,4);
x{1} = tseries(qq(2010,1):qq(2015,4),randn(24,3)*rand);
x{2} = tseries(qq(2010,1):qq(2015,4),randn(24,3)*rand);
x{3} = tseries(qq(2010,1):qq(2015,4),randn(24,3)*rand);
x{4} = tseries(qq(2010,1):qq(2015,4),randn(24,3)*rand);

%% Create a style structure
sty = struct();

sty.title.fontsize = 12;
sty.title.fontweight = 'bold';

sty.axes.xgrid = 'on';
sty.axes.ygrid = 'on';
sty.axes.tight = true;

sty.axes.ylim = [ ... %?styleprocessor?
    '!! ylim = get(H,''ylim'');', ...
    'k = 0.05*(ylim(2)-ylim(1));', ...
    'SET = [ylim(1)-k,ylim(2)+k];' ];

sty.xlabel.string = 'quarters';

sty.line.color = {'blue','red'}; %?lessvalues?
sty.line.linestyle = {'-','--',':'};
sty.line.linewidth = {1,2,2};

sty.highlight.facecolor = [1,0.8,0.8];

%% Create report
R = report.new('','orientation','portrait');

R.figure('This is a figure...', ...
    'subplot',[3,2], ...
    'highlight',qq(2012,1):qq(2013,4),'style',sty);

for i = 1 : 4    
    R.graph(sprintf('Graph #%g',i));
        R.series('',x{i});
end

%% Publish report
R.publish('report1.pdf','display',false);
catch err
  if ~isempty(strfind(err.message,'class not found: genericobj'))
    error('expected error:: octave unexpectedly changed working directory to ~');
  else
    rethrow(err);
  end
end
