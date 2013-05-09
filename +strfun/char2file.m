function char2file(char,fname,type)
% char2file  Write character string to text file.
%
% Syntax
% =======
%
%     strfun.char2file(c,filename)
%     strfun.char2file(c,filename,type)
%
% Input arguments
% ================
%
% * `c` [ char ] - Character string that will be written to the file.
%
% * `filename` [ char ] - Name of the file.
%
% * `type` [ char ] - Form and precision of the data written to the file.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if nargin < 3
   type = 'char';
end

%**************************************************************************

fid = fopen(fname,'w+');
if fid == -1
  error('IRIS:filewrite:cannotOpenFile', ...
     'Cannot open file ''%s'' for writing.',fname);
end

if iscellstr(char)
   char = sprintf('%s\n',char{:});
   if ~isempty(char)
      char(end) = '';
   end
end

count = fwrite(fid,char,type);
if count ~= length(char)
   fclose(fid);
   error('IRIS:filewrite:cannotWrite', ...
      'Cannot write character string to file ''%s''.',fname);
end

fclose(fid);

end
