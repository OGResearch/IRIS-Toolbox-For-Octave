function S = alt2str(Alt,Format,To)
% alt2str  [Not a public function] Convert vector to compact list.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox. 2008/10/20.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    Format = strtrim(Format);
catch %#ok<CTCH>
    Format = '#%g';
end

try
    To = strtrim(To);
catch %#ok<CTCH>
    To = '..';
end

if islogical(Alt)
    Alt = find(Alt);
end
Alt = Alt(:).';

%--------------------------------------------------------------------------

S = '';
if isempty(Alt)
    return
end

n = length(Alt);
c = cell(1,n);
for i = 1 : n
    c{i} = sprintf([' ',Format],Alt(i));
end

d = diff(Alt) == 1;
d1 = [false,d];
d2 = [d,false];
inx = d1 & d2;
c(inx) = {'-'};
S = [c{:}];
S = regexprep(S,'-+ ',To);

end