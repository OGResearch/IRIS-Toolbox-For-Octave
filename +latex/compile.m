function x = compile(inputfilename,varargin)
% compile  [Not a public function] Compile latex file to DVI, PS or PDF.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

default = {...
  'display',true,@islogical,...
  'output','dvi',@(x) any(strcmpi(x,{'dvi','ps','pdf'})),...
  'pdflatex',true,@islogical,...
};
%  'papersize','a4',@(x) any(strcmpi(x,{'a4','letter','executive'})),...
%  'orientation','portrait',@(x) any(strcmpi(x,{'portrait','landscape'})),...
options = passvalopt(default,varargin{:});
options.output = lower(options.output);

%**************************************************************************

config = irisget();

switch options.output
case 'dvi'
   if isempty(config.latexpath)
      error('LaTeX.exe not found. Cannot use COMPILE with ''output'' set to ''DVI''.');
   end
case 'ps'
   if isempty(config.latexpath)
      error('LaTeX.exe not found. Cannot use COMPILE with ''output'' set to ''PS''.');
   end
   if isempty(config.dvipspath)
      error('DVIPS.exe not found. Cannot use COMPILE with ''output'' set to ''PS''.');
   end
case 'pdf'
   if isempty(config.pdflatexpath)
      error('PDFLaTeX.exe not found. Cannot use COMPILE with ''output'' set to ''PDF''.');
   end
end

% Tempfile to catch latex.exe output if display == false.
tempfile = tempname(cd());

[inputpath,inputtitle] = fileparts(inputfilename);

thisdir = cd();
cd(inputpath);
inputpath = cd();
cd(thisdir);

% Compile DVI.
if any(strcmpi(options.output,{'dvi','ps'})) || (strcmpi(options.output,'pdf') && ~options.pdflatex)
   filename = [inputtitle,'.tex'];
   chkfilename_();
   display = '';
   if ~options.display
      display = [' >> ',tempfile];
   end
   command = ['"',config.latexpath,'" --halt-on-error "',inputtitle,'" ',display];
   execute_();
   if ~options.display
      delete(tempfile);
   end
   dvifilename = [inputtitle,'.dvi'];
end

% Convert DVI to PS.
if strcmpi(options.output,'ps')
   filename = [inputtitle,'.dvi'];
   chkfilename_();
   display = '';
   if ~options.display
      display = ' -q*';
   end
   command = ['"',config.dvipspath,'"',display,' "',inputtitle,'"'];
   execute_();
   psfilename = [inputtitle,'.ps'];
end

% Convert DVI to PDF.
if strcmpi(options.output,'pdf') && ~options.pdflatex
   filename = [inputtitle,'.dvi'];
   chkfilename_();
   command = ['"',config.dvipdfmpath,'"',' "',inputtitle,'"'];
   execute_();
   pdffilename = [inputtitle,'.pdf'];
end

% Run PDFLATEX to compile PDF.
if strcmpi(options.output,'pdf') && options.pdflatex
   filename = [inputtitle,'.tex'];
   chkfilename_();
   display = '';
   if ~options.display
      display = ' -quiet';
   end
   command = ['"',config.pdflatexpath,'" --halt-on-error',display,' "',inputtitle,'"'];
   execute_();
   pdffilename = [inputtitle,'.pdf'];
   disp(' ');
end
   
   function execute_()
      cd(inputpath);
      system(command);
      cd(thisdir);
   end
   
   function chkfilename_()
      if exist(fullfile(inputpath,filename)) ~= 2
         error('Cannot find the file ''%s'' in the working directory ''%s''.',filename,inputpath);
      end
   end

end
