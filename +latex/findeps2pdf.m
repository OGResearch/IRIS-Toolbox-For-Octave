function findeps2pdf(inputfile)
% findeps2pdf  Find references to EPS files in a latex code and
% convert the files to PDF.

% Find EPS figures.
c = file2char(inputfile);
list = regexpi(c,'(?<=\{)\w+\.eps(?=\})','match');

if ~isempty(list)
   thisDir = pwd();
   inputpath = fileparts(inputfile);
   if ~isempty(inputpath)
      cd(inputpath);
   end
   list = unique(list);
   % Convert EPS figures to PDF inside outputDir.
   latex.epstopdf(list);
   % Change figure extensions to PDF in latex file.
   c = regexprep(c,'(?<=\{)(\w+\.)eps(?=\})','$1pdf','ignorecase');
   char2file(c,inputfile);
   while ~isequal(pwd(),thisDir)
       cd(thisDir);
   end
end

end
