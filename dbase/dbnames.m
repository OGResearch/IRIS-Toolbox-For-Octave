function Name = dbnames(D,varargin)
% dbnames  List of database entries filtered by name and/or class.
%
% Syntax
% =======
%
%     List = dbnames(D,...)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database.
%
% Output arguments
% =================
%
% * `List` [ cellstr ] - List of input database entries that pass the name
% or class test.
%
% Options
% ========
%
% * `'nameFilter='` [ char | *`Inf`* ] - Regular expression against which
% the database entry names will be matched; `Inf` means all names will be
% matched.
%
% * `'classFilter='` [ char | *`Inf`* ] - Regular expression against which
% the database entry class names will be matched; `Inf` means all classes
% will be matched.
%
% Description
% ============
%
% Example
% ========
%
% Notice the differences in the following calls to `dbnames`:
%
%     dbnames(d,'nameFilter=','L_')
%
% matches all names that contain `'L_'` (at the beginning, in the middle,
% or at the end of the string), such as `'L_A'`, `'DL_A'`, `'XL_'`, or just
% `'L_'`.
%
%     dbnames(d,'nameFilter=','^L_')
%
% matches all names that start with `'L_'`, suc as `'L_A'` or `'L_'`.
%
%     dbnames(d,'nameFilter=','^L_.')
%
% matches all names that start with `'L_'` and have at least one more
% character after that, such as `'L_A'` (but not `'L_'`).
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

opt = passvalopt('dbase.dbnames',varargin{:});

%--------------------------------------------------------------------------

% Empty name filter and empty class filter returns empty list.
if isempty(opt.namefilter) && isempty(opt.classfilter)
   Name = {};
   return
end

% Get the database's field names. Infs in both filters return all names.
Name = fieldnames(D).';
if isequal(opt.namefilter,Inf) && isequal(opt.classfilter,Inf)
   return
end
n = length(Name);

% Filter the names.
if isequal(opt.namefilter,Inf)
   nameTest = true([1,n]);
elseif isempty(opt.namefilter)
   nameTest = false([1,n]);
else
   x = regexp(Name,opt.namefilter,'once');
   nameTest = ~cellfun(@isempty,x);
end
   
% Filter the classes.
if isequal(opt.classfilter,Inf)
   classTest = true([1,n]);
elseif isempty(opt.classfilter)
   classTest = false([1,n]);
else
   c = cellfun(@class,struct2cell(D),'uniformOutput',false).';
   x = regexp(c,opt.classfilter,'once');
   classTest = ~cellfun(@isempty,x);
end

% Return the names tha pass both tests.
Name = Name(nameTest & classTest);

end