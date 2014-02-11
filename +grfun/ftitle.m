function h = ftitle(varargin)
% ftitle  Add title to figure window.
%
% Syntax
% =======
%
%     AA = grfun.ftitle(Titles,...)
%     AA = grfun.ftitle(FF,Titles,...)
%
% Input arguments
% ================
%
% * `FF` [ numeric | struct ] - Handle to a figure window or windows; or a
% struct that includes a field name `figure`.
%
% * `Titles` [ cellstr | char ] - Text string to be centred, or cell array
% of strings to be placed on the LHS, centred, and on the RHS of the
% figure.
%
% Output arguments
% =================
%
% * `AA` [ numeric ] - Handle or handles to annotation objects.
%
% Options
% ========
%
% * `'location='` [ *`'north'`* | `'west'` | `'east'` | `'south'` ] -
% Location of the figure title: top, left edge sideways, right edge
% sideways, bottom.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if all(ishandle(varargin{1}(:)))
    hfig = varargin{1};
    varargin(1) = [];
elseif isstruct(varargin{1}) ...
        && isfield(varargin{1},'figure') ...
        && all(ishandle(varargin{1}.figure(:)))
    hfig = varargin{1}.figure;
    varargin(1) = [];    
else
    hfig = gcf();
end

string = varargin{1};
varargin(1) = [];

if ischar(string)
    string = {string};
end

switch length(string)
    case 0
        string = {'','',''};
    case 1
        string = [{''},string,{''}];
    case 2
        string = [string,{''}];
end

[opt,varargin] = passvalopt('grfun.ftitle',varargin{:});

%--------------------------------------------------------------------------
%#ok<*AGROW>

string = strrep(string,'\\',sprintf('\n'));

switch lower(opt.location)
    case 'north'
        x1 = 0;
        x2 = 0.5;
        x3 = 1;
        y1 = 1;
        y2 = 1;
        y3 = 1;
        rotation = 0;
        valign = 'top';
    case 'west'
        x1 = 0.01;
        x2 = 0.01;
        x3 = 0.01;
        y1 = 0;
        y2 = 0.5;
        y3 = 1;
        rotation = 90;
        valign = 'top';
    case 'east'
        x1 = 0.99;
        x2 = 0.99;
        x3 = 0.99;
        y1 = 1;
        y2 = 0.5;
        y3 = 0;
        rotation = -90;
        valign = 'top';
    case 'south'
        x1 = 0;
        x2 = 0.5;
        x3 = 1;
        y1 = 0;
        y2 = 0;
        y3 = 0;
        rotation = 0;
        valign = 'bottom';
end

textoptions = { ...
    'rotation',rotation, ...
    'verticalAlignment',valign, ...
    'fontWeight','bold', ...
    'lineStyle','none', ...
    };

h = [];
for ifig = hfig(:).'
    ca = get(ifig,'currentAxes');
    ax = axes('position',[0,0,1,1],'parent',ifig,'visible','off');
    
    if ~isempty(string{1})
        h(end+1) = text(x1,y1,string{1}, ...
            'parent',ax,'horizontalAlignment','left', ...
            textoptions{:},varargin{:});
    end
    if ~isempty(string{2})
        h(end+1) = text(x2,y2,string{2}, ...
            'parent',ax,'horizontalAlignment','center', ...
            textoptions{:},varargin{:});
    end
    if ~isempty(string{3})
        h(end+1) = text(x3,y3,string{3}, ...
            'parent',ax, ...
            'horizontalAlignment','right',textoptions{:},varargin{:});
    end
    set(ifig,'currentAxes',ca);
end

end