function d = plus(d1,d2)
% plus  Merge two databases entry by entry.
%
% Syntax
% =======
%
%     d = d1 + d2
%
% Input arguments
% ================
%
% * `d1` [ struct ] - First input database.
%
% * `d2` [ struct ] - Second input database.
%
% Output arguments
% =================
%
% * `d` [ struct ] - Output database with entries from both input database;
% if the same entry name exists in both databases, the second database is
% used.
%
% Description
% ============
%
% Example
% ========
%
%}


% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

names = [fieldnames(d1);fieldnames(d2)];
values = [struct2cell(d1);struct2cell(d2)];
[names,index] = unique(names,'last');
d = cell2struct(values(index),names);

end
