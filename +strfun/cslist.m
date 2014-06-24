function S = cslist(C,varargin)
% cslist  Convert cellstr to comma-separated list.
%
% Syntax
% =======
%
%     S = strfun.cslist(C)
%     S = strfun.cslist(C,...)
%
% Input arguments
% ================
%
% * `C` [ cellstr ] - Cell array of strings that will be converted to a
% comma-separated list.
%
% Output arguments
% =================
%
% * `S` [ char ] - Text string with comma-separated list.
%
% Options
% ========
%
% * `'lead='` [ char | *''* ] - Leading string at the beginning of each line.
%
% * `'spaced='` [ *`true`* | `false` ] - Insert a space after comma.
%
% * `'trail='` [ char | *empty* ] - Trailing string at the end of each
% line.
%
% * `'quote='` [ *`'none'`* | `'single'` | `'double'` ] - Enclose the list
% items in quotes.
%
% * `'wrap='` [ numeric | *`Inf`* ] - Insert line break after reaching the
% specified column.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Parse input arguments.
pp = inputParser();
pp.addRequired('list',@iscellstr);
pp.parse(C);


% Parse options.
opt = passvalopt('strfun.cslist',varargin{:});

%--------------------------------------------------------------------------

% Set up the formatting string.
switch opt.quote
    case 'single'
        format = '''%s'',';
    case 'double'
        format = '"%s",';
    otherwise
        format = '%s,';
end
if opt.spaced
    format = [format,' '];
end

% The length of the formatting string needs to be added to the length of
% each list item.
nFormat = length(format) - 2;
len = cellfun(@length,C) + nFormat;

nLead = length(opt.lead);
nTrail = length(opt.trail);

C = C(:).';
S = '';
firstRow = true;
while ~isempty(C)
    n = find(nLead + cumsum(len) + nTrail >= opt.wrap,1);
    if isempty(n)
        n = length(C);
    end
    s1 = [opt.lead,sprintf(format,C{1:n}),opt.trail];
    if ~firstRow
        S = [S,sprintf('\n')]; %#ok<AGROW>
    end
    S = [S,s1]; %#ok<AGROW>
    firstRow = false;
    C(1:n) = [];
    len(1:n) = [];
end

end