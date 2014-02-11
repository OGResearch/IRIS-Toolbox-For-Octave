function ps2pdf(list,varargin)
% ps2pdf  [Not a public function] Run PS2PDF to convert PS grapics to PDF.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

if ischar(list)
   list = regexp(list,'[^,;]+','match');
   list = strtrim(list);
end

thisdir = cd();
ps2pdf = irisget('ps2pdfpath');
if isempty(ps2pdf)
   error('iris:latex',...
      'PS2PDF path unknown. Cannot convert PS to PDF files.');
end

for i = 1 : length(list)
   [fpath,ftitle,fext] = fileparts(list{i});
   fpath = strtrim(fpath);
   if ~isempty(fpath)
      cd(fpath);
   end
   tmp = dir([ftitle,fext]);
   tmp([tmp.isdir]) = [];
   for j = 1 : length(tmp)
      command = ['"',ps2pdf,'" ',tmp(j).name];
      system(command);
   end
   cd(thisdir);
end

end
