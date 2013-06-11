function D = plus(D1,D2)
% plus  Merge two databases entry by entry.
%
% Syntax
% =======
%
%     D = D1 + D2
%
% Input arguments
% ================
%
% * `D1` [ struct ] - First input database.
%
% * `D2` [ struct ] - Second input database.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database with entries from both input database;
% if the same entry name exists in both databases, the second database is
% used.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('D1',@isstruct);
pp.addRequired('D2',@isstruct);
pp.parse(D1,D2);

%--------------------------------------------------------------------------

names = [fieldnames(D1);fieldnames(D2)];
values = [struct2cell(D1);struct2cell(D2)];
[names,inx] = unique(names,'last');
D = cell2struct(values(inx),names);

end