function [c,flag] = file2char(fname,type,lines)
% strfun.file2char  Read a text file as char or cellstr.
%
% Syntax
% =======
% 
%     c = strfun.file2char(filename)
%     c = strfun.file2char(filename,type)
%     c = strfun.file2char(filename,type,lines)
%
% Input arguments
% ================
%
% * `filename` [ char ] - Name of the file from which the text will be
% read.
%
% * `type` [ char ] - Format the ouput data. Can be `'char'` for a
% character string, `'cellstrs'` for a cell array of strings keeping new
% line characters, or `'cellstrl'` for a cell array of strings with new
% line characters removed. If not specified, `'char'` is used.
%
% * `lines` [ numeric ] - Vector of the line numbers that will be
% read. If not specified, all lines are read.
%
% Output arguments
% =================
%
% * `c` [ char ] - Character string read from the input file.
%
% Description
% ============
%}


% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if nargin < 3
   lines = Inf;
   selectLines = false;
else 
   lines(round(lines) ~= lines | lines < 1) = [];
   if isempty(lines)
      c = '';
      return
   else
      selectLines = ~isequal(lines,Inf);
   end
end

if nargin < 2 || isempty(type)
   type = 'char';
end

%**************************************************************************

if iscellstr(fname) && length(fname) == 1
   text = fname{1};
   flag = true;
   return
end

flag = true;
fid = fopen(fname,'r');
if fid == -1
   if ~exist(fname,'file')
      error('FILE2CHAR cannot find file ''%s''.',fname);
   else
      error('FILE2CHAR cannot open file ''%s'' for reading.',fname);
   end
end

if strcmpi(type,'cellstrl')
   % Remove new line characters.
   c = {};
   while ~feof(fid)
      c{end+1} = fgetl(fid);
   end
   if selectLines
      n = length(c);
      lines(lines > n) = [];
      c = c(lines);
   end
elseif strcmpi(type,'cellstrs') || selectLines
   % Keep new line characters.
   c = {};
   while ~feof(fid)
      c{end+1} = fgets(fid);
   end
   if selectLines
      n = length(c);
      lines(lines > n) = [];
      c = c(lines);
   end
   if ~strcmpi(type,'cellstrs')
      c = [c{:}];
   end
else 
   c = char(transpose(fread(fid,type)));
end

if fclose(fid) == -1
   warning('iris:utils', ...
      'FILE2CHAR cannot close file ''%s'' after reading.',fname);
end

end