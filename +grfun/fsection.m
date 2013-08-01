function h = fsection(Sec,varargin)

[opt,varargin] = passvalopt('grfun.fsection',varargin{:});

%--------------------------------------------------------------------------

fig = figure();
ax = axes('visible','off');

h = text(0.5,0.5,Sec, ...
    'parent',ax, ...
    'horizontalAlignment','center', ...
    'verticalAlignment','middle', ...
    varargin{:});

if ~isempty(opt.orient)
    orient(opt.orient);
end

if ~isempty(opt.addto)
    print('-dpsc',opt.addto,'-append');
end

if opt.close
    close(fig);
end

end